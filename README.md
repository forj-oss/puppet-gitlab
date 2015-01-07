# GitLab

[![License](http://img.shields.io/:license-ALv2-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.html)

This module installs [GitLab](https://about.gitlab.com/) git repository management.

# How to use

##Simple config:

```puppet
include gitlab
```

After the complete installation you can access GitLab at port 80 with the following credentials:

1. In your browser go to http://server_address:80
2. Login using: root/5iveL!fe

# Parameters
* `vhost_name`       : Hotname for the server (default: '$::fqdn')
* `gitlab_user`      : User installed for Gitlab (default: 'git')
* `gitlab_user_home` : Home Path for the User (default: '/home/git')
* `gitlab_group`     : Group installed for Gitlab (default: 'git')
* `gitlab_repo`      : Source repo for Gitlab Installation (default: 'https://gitlab.com/gitlab-org/gitlab-ce.git')
* `gitlab_branch`    : Branch to download from source (default: '7-1-stable')
* `gitlab_db_type`   : Database provider to use either mysql or postgresql (default: mysql)
* `gitlab_db_user`   : Database user (default: 'git')
* `gitlab_db_pass`   : Database user password (default: 'changeme')

# License

Released under the Apache 2.0 licence

# Contact

* Oscar (homeless) Romero - <homeless@hp.com>
* [IRC channel](http://webchat.freenode.net/?channels=forj)


# Known Issues:

* ...

# Support

Please log tickets and issues at our [GitHub repository](https://github.com/forj-oss/puppet-gitlab)

# Contribute:

[Contribute to this project here](http://docs.forj.io/en/latest/dev/contribute.html)
