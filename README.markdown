ops
===

Configuration for cloud things.

This repo doesn't contain my machine configurations, those are in [nixfiles][].

[nixfiles]: https://github.com/barrucadu/nixfiles

aws
---

Terraform configuration I use for:

- backups, described in [this memo](https://memo.barrucadu.co.uk/backups.html)
- concourse secrets management
- notifications, used for my monitoring, described in [this memo](https://memo.barrucadu.co.uk/monitoring.html)
- dns, described below

concourse
---------

Concourse [resource types][] and [pipelines][] for my CI/CD server.

[resource types]: https://concourse-ci.org/resource-types.html
[pipelines]: https://concourse-ci.org/pipelines.html

### feed-resource

Read-only access to an atom or RSS feed.

**Source parameters:**

- `uri`

### rsync-resource

Read/write access to another filesystem over `rsync`.

**Source parameters:**

- `server`
- `user` (default `concourse-deploy-robot`)
- `remote_dir`
- `private_key`
- `port` (default `22`)

**Put parameters:**

- `rsync_args` (default `[]`): extra arguments to pass to rsync
- `path` (default `""`): path to copy from

### pipelines

Pipelines mostly live in the repo they relate to, for example [this
pipeline for testing & publishing new dejafu versions][], or [this
pipeline for publishing my RPG blog][], but a few live here.

There are three to deploy things from this repo:

- aws, for running Terraform
- concourse, for building the resource type docker images and for adding secrets
- dns, for running OctoDNS
- github, for running my GitHub configurator daily

And also one which doesn't have another repo to call home:

- www-uzbl-org, for deploying [www.uzbl.org][], which I host, but
  don't own the repo of

[this pipeline for testing & publishing new dejafu versions]: https://github.com/barrucadu/dejafu/blob/master/concourse/pipeline.yml
[this pipeline for publishing my RPG blog]: https://github.com/barrucadu/lookwhattheshoggothdraggedin.com/blob/master/concourse/pipeline.yml
[ap.barrucadu.co.uk]: https://ap.barrucadu.co.uk/main/all
[social.lainon.life]: https://social.lainon.life/main/all
[www.uzbl.org]: https://www.uzbl.org/

dns
---

OctoDNS configuration for all of my domain names, which are hosted in
AWS Route53.

For domains which don't send email, I follow [this guidance on
GOV.UK][].

[this guidance on GOV.UK]: https://www.gov.uk/guidance/protect-domains-that-dont-send-email

github
------

A script to set some default permissions on my GitHub repos:

PR merging rules for all repos:

- allow a PR to be merged by commit, but not by squash or rebase
- delete a PR branch after merge

Branch protection for master, if there are GitHub Actions defined:

- require the lint & test actions to pass
- don't require up-to-date branches before merging
- don't allow force pushes
- don't require a linear history
- include admins in these restrictions
