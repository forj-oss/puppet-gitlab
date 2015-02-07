# == Class: gitlab::install
# Copyright 2014 Hewlett-Packard Development Company, L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
#
class gitlab::install
{
  # Configure GitLab Database
  class { 'gitlab::db_config': }

  # Download GitLab Repository/Branch
  vcsrepo { "${::gitlab::gitlab_user_home}/gitlab":
    ensure   => present,
    provider => git,
    source   => $::gitlab::gitlab_repo,
    revision => $::gitlab::gitlab_branch,
    user     => $::gitlab::gitlab_user,
    require  => Class['gitlab::db_config'],
  }

  # Copy Configuration Files
  file { "${::gitlab::gitlab_user_home}/gitlab/config/gitlab.yml":
    ensure  => file,
    owner   => $::gitlab::gitlab_user,
    group   => $::gitlab::gitlab_group,
    mode    => '0644',
    content => template('gitlab/config/gitlab.yml.erb'),
    require => Vcsrepo["${::gitlab::gitlab_user_home}/gitlab"],
  }
  file { "${::gitlab::gitlab_user_home}/gitlab-satellites":
    ensure  => directory,
    owner   => $::gitlab::gitlab_user,
    group   => $::gitlab::gitlab_group,
    mode    => '0750',
    require => Vcsrepo["${::gitlab::gitlab_user_home}/gitlab"],
  }
  file { "${::gitlab::gitlab_user_home}/gitlab/config/unicorn.rb":
    ensure  => file,
    owner   => $::gitlab::gitlab_user,
    group   => $::gitlab::gitlab_group,
    mode    => '0644',
    content => template('gitlab/config/unicorn.rb.erb'),
    require => Vcsrepo["${::gitlab::gitlab_user_home}/gitlab"],
  }
  file { "${::gitlab::gitlab_user_home}/gitlab/config/initializers/rack_attack.rb":
    ensure  => file,
    owner   => $::gitlab::gitlab_user,
    group   => $::gitlab::gitlab_group,
    mode    => '0644',
    content => template('gitlab/config/rack_attack.rb.erb'),
    require => Vcsrepo["${::gitlab::gitlab_user_home}/gitlab"],
  }
  file { "${::gitlab::gitlab_user_home}/gitlab/config/database.yml":
    ensure  => file,
    owner   => $::gitlab::gitlab_user,
    group   => $::gitlab::gitlab_group,
    mode    => '0644',
    content => template("gitlab/config/database-${::gitlab::gitlab_db_type}.yml.erb"),
    require => Vcsrepo["${::gitlab::gitlab_user_home}/gitlab"],
  }
  file { '/etc/init.d/gitlab':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('gitlab/gitlab.init.erb'),
    require => Vcsrepo["${::gitlab::gitlab_user_home}/gitlab"],
  }
  file { '/etc/default/gitlab':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    content => template('gitlab/gitlab.default.erb'),
    require => Vcsrepo["${::gitlab::gitlab_user_home}/gitlab"],
  }
  file { '/etc/logrotate.d/gitlab':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    content => template('gitlab/logrotate.conf.erb'),
    require => Vcsrepo["${::gitlab::gitlab_user_home}/gitlab"],
  }

  # Install RVM
  rbenv::install { $::gitlab::gitlab_user:
    group   => $::gitlab::gitlab_group,
    home    => $::gitlab::gitlab_user_home,
    require => Vcsrepo["${::gitlab::gitlab_user_home}/gitlab"],
  }
  file { "${::gitlab::gitlab_user_home}/.bashrc":
    ensure  => link,
    target  => "${::gitlab::gitlab_user_home}/.profile",
    require => Rbenv::Install[$::gitlab::gitlab_user],
  }
  rbenv::compile { 'gitlab/ruby':
    user    => $::gitlab::gitlab_user,
    group   => $::gitlab::gitlab_group,
    home    => $::gitlab::gitlab_user_home,
    ruby    => $::gitlab::gitlab_ruby_ver,
    global  => true,
    require => File["${::gitlab::gitlab_user_home}/.bashrc"],
  }

  # GitLab Installation
  #TODO: Add parameter for mysql usage instead of postgresql
  if $::gitlab::gitlab_db_type == 'postgresql' {
    $exclude_groups = 'mysql'
  }
  else {
    $exclude_groups = 'postgresql'
  }
  Exec { path => [ "${::gitlab::gitlab_user_home}/.rbenv/shims:/usr/bin:/usr/sbin:/bin:/usr/local/bin", ] }
  exec { 'bundle gitlab':
    command   => "bundle install --deployment --without development test aws ${exclude_groups}",
    user      => $::gitlab::gitlab_user,
    cwd       => "${::gitlab::gitlab_user_home}/gitlab",
    timeout   => 0,
    unless    => 'bundle check',
    logoutput => true,
    require   => Rbenv::Compile['gitlab/ruby'],
  }
  exec { 'bundle exec gitlab-shell':
    command     => "bundle exec rake gitlab:shell:install[v${::gitlab::gitlab_shell_ver}]",
    user        => $::gitlab::gitlab_user,
    cwd         => "${::gitlab::gitlab_user_home}/gitlab",
    environment => ['RAILS_ENV=production',
                    'REDIS_URL=unix:/var/run/redis/redis.sock'],
    logoutput   => true,
    timeout     => 0,
    creates     => "${::gitlab::gitlab_user_home}/repositories",
    require     => Exec['bundle gitlab'],
  }
  exec { 'bundle exec gitlab-setup':
    command   => '/usr/bin/yes yes | bundle exec rake gitlab:setup RAILS_ENV=production',
    user      => $::gitlab::gitlab_user,
    cwd       => "${::gitlab::gitlab_user_home}/gitlab",
    creates   => "${::gitlab::gitlab_user_home}/.setup_finished",
    timeout   => 0,
    logoutput => true,
    require   => Exec['bundle exec gitlab-shell'],
  }
  file { "${::gitlab::gitlab_user_home}/.setup_finished":
    ensure  => file,
    mode    => '0644',
    owner   => $::gitlab::gitlab_user,
    group   => $::gitlab::gitlab_group,
    require => Exec['bundle exec gitlab-setup'],
  }
  exec { 'compile gitlab assets':
    command => 'bundle exec rake assets:precompile RAILS_ENV=production',
    user    => $::gitlab::gitlab_user,
    timeout => 0,
    cwd     => "${::gitlab::gitlab_user_home}/gitlab",
    require => File["${::gitlab::gitlab_user_home}/.setup_finished"],
    #refreshonly => true,
  }

  #### Install NGINX
  if (!defined(Package['nginx'])) {
    package { 'nginx' :
    ensure  => present,
    }
  }
  file { '/etc/nginx/sites-available/default':
    ensure  => absent,
    require => Package['nginx'],
  }
  file { '/etc/nginx/sites-available/gitlab':
    ensure  => file,
    content => template('gitlab/gitlab.vhost.erb'),
    require => Vcsrepo["${::gitlab::gitlab_user_home}/gitlab"],
  }
  file { '/etc/nginx/sites-enabled/gitlab':
    ensure  => 'link',
    target  => '/etc/nginx/sites-available/gitlab',
    require => File['/etc/nginx/sites-available/gitlab'],
  }
}
