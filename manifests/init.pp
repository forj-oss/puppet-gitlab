# == Class: gitlab
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
class gitlab
(
  $vhost_name       = $gitlab::params::vhost_name,
  $gitlab_user      = $gitlab::params::gitlab_user,
  $gitlab_user_home = $gitlab::params::gitlab_user_home,
  $gitlab_group     = $gitlab::params::gitlab_group,
  $gitlab_ruby_ver  = $gitlab::params::gitlab_ruby_ver,
  $gitlab_repo      = $gitlab::params::gitlab_repo,
  $gitlab_branch    = $gitlab::params::gitlab_branch,
  $gitlab_shell_ver = $gitlab::params::gitlab_shell_ver,
  $gitlab_db_type   = $gitlab::params::gitlab_db_type,
  $gitlab_db_user   = $gitlab::params::gitlab_db_user,
  $gitlab_db_pass   = $gitlab::params::gitlab_db_pass,
  $mail_address     = '',
  $mail_port        = '',
  $mail_user        = '',
  $mail_password    = '',
  $mail_domain      = '',
) inherits gitlab::params
{
  #Validate parameters
  validate_string(
    $gitlab_user,
    $gitlab_user_home,
    $gitlab_group,
    $gitlab_ruby_ver,
    $gitlab_repo,
    $gitlab_branch,
    $gitlab_shell_ver,
    $gitlab_db_type,
    $gitlab_db_user,
    $gitlab_db_pass
  )

  if $mail_address != '' {
    class { '::gitlab::mail':
      address  => $mail_address,
      port     => $mail_port,
      user     => $mail_user,
      password => $mail_password,
      domain   => $mail_domain,
      notify   => Class['gitlab::service'],
    }
    Class['gitlab::install'] ->
    Class['gitlab::mail']
  }

  anchor { 'gitlab::begin': } ->
  class { 'gitlab::packages': } ->
  class { 'gitlab::setup_user': } ->
  class { 'gitlab::install': } ->
  class { 'gitlab::service': } ->
  class { 'gitlab::configure::install_scripts': } ->
  anchor { 'gitlab::end': }
}
