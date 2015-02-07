# == Class: gitlab::install_scripts
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
class gitlab::configure::install_scripts(
  $url      = 'http://localhost/api/v3',
  $password = '5iveL!fe',
){
  #set token key to config.sh
  $token_file = 'config.sh'
  exec { 'Creating config.sh with token':
    command => join( [
                "curl -s -X POST ${url}/session",
                "--data 'login=root&password=${password}' ",
                "| sed -E 's/.*token\":\"(.*)\".*/TOKEN=\"\1\"/g' ",
                "> ${token_file}",
                "&& echo \"\nURL='${url}'\" >> ${token_file}",
                ] ,' '),
    path    => '/usr/local/bin:/usr/bin:/bin',
    cwd     => $gitlab::gitlab_user_home,
    unless  => "test -f ${token_file} && grep 'TOKEN=' ${token_file}",
  } ->
  file { "${gitlab::gitlab_user_home}/${token_file}":
    ensure => 'present',
    mode   => '0440',
  }

  File {
    ensure => 'file',
    owner  => $gitlab::gitlab_user,
    group  => $gitlab::gitlab_group,
    mode   => '0550',
  }

  #user script
  file { "${gitlab::gitlab_user_home}/user.sh":
    source => 'puppet:///modules/gitlab/user.sh',
  }
  #project script
  file { "${gitlab::gitlab_user_home}/project.sh":
    source => 'puppet:///modules/gitlab/project.sh',
  }
  #syshook script
  file { "${gitlab::gitlab_user_home}/syshook.sh":
    source => 'puppet:///modules/gitlab/syshook.sh',
  }
  #group script
  file { "${gitlab::gitlab_user_home}/group.sh":
    source => 'puppet:///modules/gitlab/group.sh',
  }
}