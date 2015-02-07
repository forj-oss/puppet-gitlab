# == Class: gitlab::project
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
define gitlab::configure::project (
  #$name                      = '',
  $visibility_level           = '10',
  $hook_url                   = '',
  $hook_push_events           = true,
  $hook_issues_events         = true,
  $hook_merge_requests_events = true,
  $hook_tag_push_events       = true,
  $ensure                     = 'present',
) {

  if $visibility_level == '' {
    fail('Visibility level is required.')
  }

  validate_string(
    $name,
    $visibility_level,
    $hook_url,
    $ensure,
  )

  validate_re($visibility_level, ['0*', '10','20'])

  if $ensure == 'present' {
    $action = 'add'
  } else {
    $action = 'delete'
  }

  exec { "CreatingProject:${name}":
    command => join( [
                "bash project.sh --${action} ",
                "'${name}' '${visibility_level}' '${hook_url}' '${hook_push_events}' '${hook_issues_events}' ",
                "'${hook_merge_requests_events}' '${hook_tag_push_events}' ",
                ] ,' '),
    path    => '/usr/local/bin:/usr/bin:/bin',
    cwd     => $gitlab::gitlab_user_home,
  }

}