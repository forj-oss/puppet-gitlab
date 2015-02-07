# == Class: gitlab::setup_user
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
class gitlab::setup_user
{
  # Group/User/Home
  group { $::gitlab::gitlab_group:
    ensure  => present,
  }
  user { $::gitlab::gitlab_user:
    ensure     => present,
    comment    => 'GitLab User',
    home       => $::gitlab::gitlab_user_home,
    gid        => $::gitlab::gitlab_group,
    shell      => '/bin/bash',
    membership => 'minimum',
    require    => Group[$::gitlab::gitlab_group],
  }
  file { $::gitlab::gitlab_user_home:
    ensure  => directory,
    owner   => $::gitlab::gitlab_user,
    group   => $::gitlab::gitlab_group,
    mode    => '0644',
    require => User[$::gitlab::gitlab_user],
  }
}