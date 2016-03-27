# Archiving

`Archiving` is a web front-end for an easier and more simplified backup scheduling with Bacula

## Features

* Oauth2 user authentication
* Shibboleth user authentication
* Multiple users per backed up client
* Automated Bacula Director configuration
* Flexible backup Scheduling
* Flexible restore process
* Graph stats
* Admin interface

## Archiving Installation

`Archiving` was developed to be deployed using standard debian jessie (stable) packages and
practices. It does not require bundler for production, but is should be pretty
straightforward to set it up using bundler on other platforms.

## Setup Bacula

You need a running Baclua director for `Archiving` to be functional.

At the end of `bacula-dir.conf` file there must be:

```
@|"sh -c 'for f in /etc/bacula/admindefs/pools/*.conf ; do echo @${f} ; done'"
@|"sh -c 'for f in /etc/bacula/clientdefs/clients/*.conf ; do echo @${f} ; done'"
@|"sh -c 'for f in /etc/bacula/clientdefs/jobs/*.conf ; do echo @${f} ; done'"
@|"sh -c 'for f in /etc/bacula/clientdefs/filesets/*.conf ; do echo @${f} ; done'"
@|"sh -c 'for f in /etc/bacula/clientdefs/schedules/*.conf ; do echo @${f} ; done'"
```

clientdefs and admindefs directories do not need to be there, we can create symbolic links to a
destination of our choice.

Setting custom locations enables Archiving to not require root or bacula user access to the Bacula
server.

The respective directory structure.

```
$ mkdir -p CLIENTDEFS/clients CLIENTDEFS/filesets CLIENTDEFS/jobs CLIENTDEFS/schedules
$ mkdir -p ADMINDEFS/pools
$ touch CLIENTDEFS/clients/tmp.conf CLIENTDEFS/filesets/tmp.conf CLIENTDEFS/jobs/tmp.conf CLIENTDEFS/schedules/tmp.conf ADMINDEFS/pools/tmp.conf
$ cd /etc/bacula/
$ ln -s CLIENTDEFS clientdefs
$ ln -s ADMINDEFS admindefs
```

eg:

```
$ tree clientdefs

clientdefs
├── clients
│   └── tmp.conf
├── filesets
│   └── tmp.conf
├── jobs
│   └── tmp.conf
└── schedules
    └── tmp.conf

$ tree admindefs

admindefs/
└── pools
    └── tmp.conf

```
Where `tmp.conf` is an empty file (which `Archiving` needs)

Admins now should add a Pool through archiving's admin interface. After altering pools
admininstrators should issue a

`RAILS_ENV=production rake pool:apply_ustream`

command, which sends all new configuration to the director.
Note that this command can be used to mass update the director's configuration at any time.

You will need to add an ssh key to `authorized_hosts` in order to give access to `Archiving` to
upload configuration to the Bacula server. The key's access can be limited to adding and removing
files.

## Prepare for deploy

Install dependencies and generate the configuration files by running the puppet configuration.

```
$ puppet apply /etc/puppet/manifests/site.pp
```

the following config files should exist in `/srv/archiving/shared/config`

```
bacukey # holds an ssh key that provides access to bacula-director. It must not require a passphrase
bacula.yml
bconsole.conf
database.yml
mailer.yml
secrets.yml
ssh.yml
```

Their configuration details are explained in the sample files in the repo.

## Setup Capistrano

Locally:

```
$ apt get install capistrano
$ cap production deploy

```
