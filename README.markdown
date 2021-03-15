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

And also two which don't have another repo to call home:

- pleroma, for building a [Pleroma][] docker image and deploying it to
  [ap.barrucadu.co.uk][] and [social.lainon.life][]
- www-uzbl-org, for deploying [www.uzbl.org][], which I host, but
  don't own the repo of

[this pipeline for testing & publishing new dejafu versions]: https://github.com/barrucadu/dejafu/blob/master/concourse/pipeline.yml
[this pipeline for publishing my RPG blog]: https://github.com/barrucadu/lookwhattheshoggothdraggedin.com/blob/master/concourse/pipeline.yml
[Pleroma]: https://pleroma.social/
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
