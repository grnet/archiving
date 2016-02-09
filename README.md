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
practices. It does not It does not require bundler for production, but is should be pretty
straightforward to set it up using bundler on other platforms.

## Setup Bacula

You need a running Baclua director for `Archiving` to be functional.

at the end of `bacula-dir.conf` file there must be:

```
@|"sh -c 'for f in /etc/bacula/admindefs/pools/*.conf ; do echo @${f} ; done'"
@|"sh -c 'for f in /etc/bacula/clientdefs/clients/*.conf ; do echo @${f} ; done'"
@|"sh -c 'for f in /etc/bacula/clientdefs/jobs/*.conf ; do echo @${f} ; done'"
@|"sh -c 'for f in /etc/bacula/clientdefs/filesets/*.conf ; do echo @${f} ; done'"
@|"sh -c 'for f in /etc/bacula/clientdefs/schedules/*.conf ; do echo @${f} ; done'"
```

and the respective directory structure.

```
$ cd /etc/bacula
$ mkdir -p clientdefs/clients clientdefs/filesets clientdefs/jobs clientdefs/schedules admindefs/pools
$ touch clientdefs/clients/tmp.conf clientdefs/filesets/tmp.conf clientdefs/jobs/tmp.conf clientdefs/schedules/tmp.conf admindefs/pools/tmp.conf
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

Admins now should add a Pool through archiving's admin interface.

You will need to add an ssh key to `authorized_hosts` in order to give access to `Archiving` to
upload configuration to the Bacula server.

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
