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
  $gitlab_repo      = $gitlab::params::gitlab_repo,
  $gitlab_branch    = $gitlab::params::gitlab_branch,
  $gitlab_db_type   = $gitlab::params::gitlab_db_type,
  $gitlab_db_user   = $gitlab::params::gitlab_db_user,
  $gitlab_db_pass   = $gitlab::params::gitlab_db_pass,
) inherits gitlab::params
{

  #Validate parameters
  validate_string($gitlab_user, $gitlab_group, $gitlab_user_home, $gitlab_repo,
    $gitlab_branch, $gitlab_db_type, $gitlab_db_pass)

  anchor { 'gitlab::begin': } ->
  class { 'gitlab::packages': } ->
  class { 'gitlab::install': } ->
  anchor { 'gitlab::end': }
}
