# == Class: gitlab::packages
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
class gitlab::packages
{
  exec { 'apt-get update cache':
    path    => '/bin:/usr/bin',
    command => 'apt-get update',
  }

  if (!defined(Package['build-essential'])) {
    package { 'build-essential' :
    ensure  => present,
    require => Exec['apt-get update cache'],
    }
  }

  if (!defined(Package['zlib1g-devl'])) {
    package { 'zlib1g-dev' :
    ensure  => present,
    require => Exec['apt-get update cache'],
    }
  }

  if (!defined(Package['libyaml-dev'])) {
    package { 'libyaml-dev' :
    ensure  => present,
    require => Exec['apt-get update cache'],
    }
  }

  if (!defined(Package['libssl-dev'])) {
    package { 'libssl-dev' :
    ensure  => present,
    require => Exec['apt-get update cache'],
    }
  }

  if (!defined(Package['libgdbm-dev'])) {
    package { 'libgdbm-dev' :
    ensure  => present,
    require => Exec['apt-get update cache'],
    }
  }

  if (!defined(Package['libreadline-dev'])) {
    package { 'libreadline-dev' :
    ensure  => present,
    require => Exec['apt-get update cache'],
    }
  }

  if (!defined(Package['libncurses5-dev'])) {
    package { 'libncurses5-dev' :
    ensure  => present,
    require => Exec['apt-get update cache'],
    }
  }

  if (!defined(Package['libffi-dev'])) {
    package { 'libffi-dev' :
    ensure  => present,
    require => Exec['apt-get update cache'],
    }
  }

  if (!defined(Package['curl'])) {
    package { 'curl' :
    ensure  => present,
    require => Exec['apt-get update cache'],
    }
  }

  if (!defined(Package['redis-server'])) {
    package { 'redis-server' :
    ensure  => present,
    require => Exec['apt-get update cache'],
    }
  }

  if (!defined(Package['checkinstall'])) {
    package { 'checkinstall' :
    ensure  => present,
    require => Exec['apt-get update cache'],
    }
  }

  if (!defined(Package['libxml2-dev'])) {
    package { 'libxml2-dev' :
    ensure  => present,
    require => Exec['apt-get update cache'],
    }
  }

  if (!defined(Package['libcurl4-openssl-dev'])) {
    package { 'libcurl4-openssl-dev' :
    ensure  => present,
    require => Exec['apt-get update cache'],
    }
  }

  if (!defined(Package['libicu-dev'])) {
    package { 'libicu-dev' :
    ensure  => present,
    require => Exec['apt-get update cache'],
    }
  }

  if (!defined(Package['logrotate'])) {
    package { 'logrotate' :
    ensure  => present,
    require => Exec['apt-get update cache'],
    }
  }

  if (!defined(Package['python-docutils'])) {
    package { 'python-docutils' :
    ensure  => present,
    require => Exec['apt-get update cache'],
    }
  }

  if (!defined(Package['cmake'])) {
    package { 'cmake' :
    ensure  => present,
    require => Exec['apt-get update cache'],
    }
  }

  if (!defined(Package['ruby-bundler'])) {
    package { 'ruby-bundler' :
    ensure  => present,
    require => Exec['apt-get update cache'],
    }
  }

  if (!defined(Package['libpq-dev'])) {
    package { 'libpq-dev' :
    ensure  => present,
    require => Exec['apt-get update cache'],
    }
  }

  if (!defined(Package['libmysqlclient-dev'])) {
    package { 'libmysqlclient-dev' :
    ensure  => present,
    require => Exec['apt-get update cache'],
    }
  }

  if (!defined(Package['libxslt1-dev'])) {
    package { 'libxslt1-dev' :
    ensure  => present,
    require => Exec['apt-get update cache'],
    }
  }
}
