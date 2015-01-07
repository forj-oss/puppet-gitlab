# == Class: gitlab::db_config
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
class gitlab::db_config
{
  if $::gitlab::gitlab_db_type == 'postgresql' {
    class { 'postgresql::server':
      require => Package['libpq-dev'],
    }
    postgresql::server::role { $::gitlab::gitlab_db_user:
      password_hash => postgresql_password($::gitlab::gitlab_db_user, $::gitlab::gitlab_db_pass),
      createdb      => true,
      require       => Class['postgresql::server'],
    }
    postgresql::server::db { 'gitlabhq_production':
      user     => $::gitlab::gitlab_user,
      password => postgresql_password('git', $::gitlab::gitlab_db_pass),
      owner    => $::gitlab::gitlab_db_user,
      require  => Postgresql::Server::Role['git'],
    }
    exec { 'testing sql connection':
      command => 'psql -d gitlabhq_production',
      user    => $::gitlab::gitlab_db_user,
      require => Postgresql::Server::Db['gitlabhq_production'],
    }
  }
  else {
    class { '::mysql::server':
      config_hash => {
                      'root_password' => $::gitlab::gitlab_db_pass
                      },
      require     => Package['libmysqlclient-dev'],
    }
    mysql::db { 'gitlabhq_production':
      user     => $::gitlab::gitlab_db_user,
      password => $::gitlab::gitlab_db_pass,
      host     => 'localhost',
      grant    => ['all'],
      #grant    => ['SELECT', 'LOCK TABLES', 'INSERT', 'UPDATE', 'DELETE', 'CREATE', 'DROP', 'INDEX', 'ALTER'],
      require  => Class['::mysql::server'],
    }
    exec { 'testing sql connection':
      command => "mysql -u ${::gitlab::gitlab_db_user} -p${::gitlab::gitlab_db_pass} -D gitlabhq_production",
      user    => $::gitlab::gitlab_user,
      require => Mysql::Db['gitlabhq_production'],
    }
  }
}
