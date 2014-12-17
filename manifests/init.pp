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
class gitlab (
  $tar_url          = $::gitlab::params::tar_url,
) inherits gitlab::params {

  #validate_bool($install_java)
  #validate_string($tar_url, $plugins_base_url, $user_home, $dbhost, $dbport, $dbname,
  #  $dbuser_name, $dbuser_pass, $of_port, $of_secure_port, $of_admin_pass)
  #validate_hash($of_config)
  #validate_array($plugins)

  #if $of_port == '' {
  #  fail('Openfire default port cannot be null')
  #}
  #if $of_secure_port == '' {
  #  fail('Openfire secure port cannot be null')
  #}

  anchor { 'gitlab::begin': } ->
  class { 'gitlab::packages': } ->
  class { '::gitlab::install': } ->
  anchor { 'gitlab::end': }

}
