# == Class: gitlab::mail
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
class gitlab::mail (
  $address  = '',
  $port     = '22',
  $user     = '',
  $password = '',
  $domain   = '',
){
  if $address == '' {
    fail('Address is required.')
  }
  if $user == '' {
    fail('User is required.')
  }
  if $password == '' {
    fail('Password is required.')
  }

  validate_string(
    $address,
    $port,
    $user,
    $password,
    $domain,
  )

  exec { 'Setting Delivery_Method to SMTP':
    command => "sed -i -E 's/delivery_method = :sendmail/delivery_method = :smtp/g' production.rb",
    path    => '/usr/local/bin:/usr/bin:/bin',
    cwd     => "${::gitlab::gitlab_user_home}/gitlab/config/environments",
    onlyif  => "grep 'config.action_mailer.delivery_method = :sendmail' production.rb"
  }

  file { "${::gitlab::gitlab_user_home}/gitlab/config/initializers/smtp_settings.rb":
    ensure  => file,
    owner   => $::gitlab::gitlab_user,
    group   => $::gitlab::gitlab_group,
    mode    => '0664',
    content => template('gitlab/smtp_settings.rb.erb'),
  }
}