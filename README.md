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

## API

Archiving provides access to its users with some API endpoints.

In order for a user to use the API, he must first create a token from his user page. Each user can
access all the clients where he is set as collaborator.

The basic usage of the API endpoints is:

```
curl -H 'Accept: API_VERSION' -H 'api_token: USER_TOKEN' ENDPOINT
```

Where `API_VERSION` is the version that the API uses at that time and `USER_TOKEN` the user's
personal token.

eg: 

```
curl -H 'Accept: application/archiving.v1' -H 'api_token: ABCDEF1234567890'
https://archiving.grnet.gr/api/clients
```

### GET /api/clients

Fetch all of the user's clients.

#### Request

```
curl -H 'Accept: application/archiving.v1' -H 'api_token: YOUR_TOKEN'
https://archiving.grnet.gr/api/clients
```

#### Response

```json
[
  {
    "id": 1364,
    "name": "ser-client.lan",
    "uname": "5.2.6 (21Feb12) x86_64-pc-linux-gnu,debian,jessie/sid",
    "port": 9102,
    "file_retention": "10 days",
    "job_retention": "10 days",
    "quota": 104857600,
    "last_backup": "2016-04-24T13:44:47.000+03:00",
    "files": 88,
    "space_used": 5128135,
    "collaborators": [
      "tester@example.com",
      "another_tester@example.com"
    ],
    "backup_jobs": [
      {
        "id": 30,
        "name": "backup apt logs",
        "fileset": "ser-client.lan logs auth"
      }
    ],
    "restorable_filesets": [
      {
        "id": 6,
        "name": "ser-client.lan home files"
      },
      {
        "id": 9,
        "name": "ser-client.lan logs"
      }
    ]
  }
]
```

### GET /api/clients/:id

Fetch a client that belongs to a user.

#### Request

```
curl -H 'Accept: application/archiving.v1' -H 'api_token: YOUR_TOKEN'
https://archiving.grnet.gr/api/clients/1364
```

#### Response

```json
{
  "id": 1364,
  "name": "ser-client.lan",
  "uname": "5.2.6 (21Feb12) x86_64-pc-linux-gnu,debian,jessie/sid",
  "port": 9102,
  "file_retention": "10 days",
  "job_retention": "10 days",
  "quota": 104857600,
  "last_backup": "2016-04-24T13:44:47.000+03:00",
  "files": 88,
  "space_used": 5128135,
  "collaborators": [
    "tester@example.com",
    "another_tester@example.com"
  ],
  "backup_jobs": [
    {
      "id": 30,
      "name": "backup apt logs",
      "fileset": "ser-client.lan logs auth"
    }
  ],
  "restorable_filesets": [
    {
      "id": 6,
      "name": "ser-client.lan home files"
    },
    {
      "id": 9,
      "name": "ser-client.lan logs"
    }
  ]
}
```

### POST /api/clients/:id/backup

Initiate a manual full backup for a specific job.

Needs:

* `job_id`: the job's id

#### Request

```
curl -X POST -H 'Accept: application/archiving.v1' -H 'api_token: YOUR_TOKEN' -d "job_id=30" https://archiving.grnet.gr/api/clients/1361/backup
```

#### Response

```json
{
  "message": "Job is scheduled for backup"
}
```

### POST /api/clients/:id/restore

Initiates a full restore for a specific fileset to the most recent restore point.

Needs:

* `fileset_id`: the fileset's id

Accepts:

* `location`: the restore location

> if `location` is not provided the default `/tmp/bacula_restore` is used


#### Request

```
curl -X POST -H 'Accept: application/archiving.v1' -H 'api_token: YOUR_TOKEN' -d "fileset_id=30" https://archiving.grnet.gr/api/clients/1361/backup
```

#### Response

```json
{
  "message": "Restore is scheduled"
}
```
