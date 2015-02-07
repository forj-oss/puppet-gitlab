# == Class: gitlab::group
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
define gitlab::configure::group (
  #$name        = $name,
  $path        = '',
  $members     = [],
  $projects    = [],
  $avatar_file = undef,
  $ensure      = 'present',
) {
  if $path == '' {
    fail('Group path is required.')
  }

  validate_string(
    $path,
    $ensure,
  )

  validate_array(
    $members,
    $projects,
  )

  if $ensure == 'present' {
    $action = 'add'
  } else {
    $action = 'delete'
  }

  exec { "CreatingGroup:${name}":
    command => join( [
      "bash group.sh --${action} ",
      "'${name}' '${path}'",
    ] ,' '),
    path    => '/usr/local/bin:/usr/bin:/bin',
    cwd     => $gitlab::gitlab_user_home,
  }

  if $members {
    $pre = prefix($members, "'")
    $suf = suffix($pre, "'")
    exec { "AddingUsersToGroup:${name}":
      command => join( [
        "bash group.sh --adduser '${name}'",
        join($suf, ' '),
      ] ,' '),
      path    => '/usr/local/bin:/usr/bin:/bin',
      cwd     => $gitlab::gitlab_user_home,
    }
  }

  if $projects {
    exec { "AddingProjectsToGroup:${name}":
      command => join( [
        "bash group.sh --addproject '${name}'",
        join($projects, ' '),
      ] ,' '),
      path    => '/usr/local/bin:/usr/bin:/bin',
      cwd     => $gitlab::gitlab_user_home,
    }
  }

  if $avatar_file {
    $filename = regsubst($avatar_file,'^(.+)\/([^\/]+)$','\2')
    file { "${gitlab::gitlab_user_home}/${filename}":
      ensure  => file,
      source  => $avatar_file,
      require => Exec["CreatingGroup:${name}"],
    } ->
    exec { "CreatingGroupAvatar:${name}":
      command => join( [
        'bash group.sh --avatar ',
        "'${name}' '${filename}' '${gitlab::gitlab_db_type}'",
      ] ,' '),
      path    => '/usr/local/bin:/usr/bin:/bin',
      cwd     => $gitlab::gitlab_user_home,
    }
  }
}
