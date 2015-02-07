# == Class: gitlab::user
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
define gitlab::configure::user (
  $email                 = $name,
  $password              = '5iveL!fe',
  $username              = '',
  $real_name             = '',
  $projects_limit        = 0,
  $is_admin              = false,
  $can_create_group      = true,
  $avatar_file           = undef,
  $ensure                = 'present',
) {

  if $password == '' {
    fail('Password is required.')
  }
  if $username == '' {
    fail('Username is required.')
  }
  if $real_name == '' {
    fail('User real name is required.')
  }

  validate_bool(
    $is_admin,
    $can_create_group,
  )

  validate_string(
    $email,
    $password,
    $username,
    $real_name,
    $ensure,
  )

  if $ensure == 'present' {
    $action = 'add'
  } else {
    $action = 'delete'
  }

  exec { "CreatingUser:${email}":
    command => join( [
                "bash user.sh --${action} ",
                "'${email}' '${password}' '${username}' '${real_name}'",
                ] ,' '),
    path    => '/usr/local/bin:/usr/bin:/bin',
    cwd     => $gitlab::gitlab_user_home,
  }

  if $avatar_file {
    $filename = regsubst($avatar_file,'^(.+)\/([^\/]+)$','\2')
    file { "${gitlab::gitlab_user_home}/${filename}":
      ensure  => file,
      source  => $avatar_file,
      require => Exec["CreatingUser:${email}"],
    } ->
    exec { "CreatingUserAvatar:${email}":
      command => join( [
        'bash user.sh --avatar ',
        "'${email}' '${filename}' '${gitlab::gitlab_db_type}'",
      ] ,' '),
      path    => '/usr/local/bin:/usr/bin:/bin',
      cwd     => $gitlab::gitlab_user_home,
    }
  }

}