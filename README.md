# Relaton API

## Getting Started

![](https://github.com/relaton/relaton.org/workflows/GitHub%20CI/badge.svg)
[![View performance data on
Skylight](https://badges.skylight.io/rpm/PIVJdcAuqhzA.svg?token=BUfX6VJ06XPoc8ZDBC8h3U8JWszSRXyJGnMHTvYP2nE)](https://www.skylight.io/app/applications/PIVJdcAuqhzA)
[![View performance data on
Skylight](https://badges.skylight.io/typical/PIVJdcAuqhzA.svg?token=BUfX6VJ06XPoc8ZDBC8h3U8JWszSRXyJGnMHTvYP2nE)](https://www.skylight.io/app/applications/PIVJdcAuqhzA)

## Usage

### Fetch a standard

The `/api/standard` endpoint allow us to fetch any of the supported standards.

**Request**

```
Method: GET
Endpoint: /api/standard
Content-Type: application/json
Parameters: code, year, document_format

Example: /api/standard?code=ISO 19011&year=2011&document_format=json
```

**Response**

```
Status: 200
Content-Type: application/json
Body:

{
  type: "ISO",
  code: "ISO 19011",
  document: {
    id: "ISO19011-2011",
    .............
  },
  updated_at: "2019-10-10T11:03:11Z"
}
```

Note: In the underneath, it is using the [relaton
library](https://github.com/relaton/relaton), so please check that documentation
for all supported standards.


## Development

### Native development

After you have cloned this repo, run this setup script to set up your machine
with the necessary dependencies to run and test this app:

```sh
% ./bin/setup
```

It assumes you have a machine equipped with Ruby, Postgres, etc. If not, set up
your machine with [this script].

After setting up, you can run the application using [Heroku Local]:

```sh
% heroku local

# or plain old
bin/rails server
```

### Development with docker

If you prefer to run this application with docker, then you need to follow the
following steps.

1. Copy the environment variables

```sh
cp .samplle.env .env
vim .env
```

2. Setup and Run the app

```sh
# setup / rebuild
make setup

# run - no rebuild
make up
```

The makefile also includes couple of other target to run the test suite or
console in those containers. Please check out the `Makefile` for more details

## Guidelines

Use the following guides for getting things done, programming well, and
programming in style.

* [Protocol](http://github.com/thoughtbot/guides/blob/master/protocol)
* [Best Practices](http://github.com/thoughtbot/guides/blob/master/best-practices)
* [Style](http://github.com/thoughtbot/guides/blob/master/style)

## Contributing

First, thank you for contributing! We love pull requests from everyone. By
participating in this project, you hereby grant [Ribose Inc.][riboseinc] the
right to grant or transfer an unlimited number of non exclusive licenses or
sub-licenses to third parties, under the copyright covering the contribution
to use the contribution by all means.

Here are a few technical guidelines to follow:

1. Open an [issue][issues] to discuss a new feature.
1. Write tests to support your new feature.
1. Make sure the entire test suite passes locally and on CI.
1. Open a Pull Request.
1. [Squash your commits][squash] after receiving feedback.
1. Party!

## Deploying

If you have previously run the `./bin/setup` script,
you can deploy to staging and production with:

```sh
% ./bin/deploy staging
% ./bin/deploy production
```

[riboseinc]: https://www.ribose.com
[this script]: https://github.com/thoughtbot/laptop
[issues]: https://github.com/metanorma/relaton.org/issues
[Heroku Local]: https://devcenter.heroku.com/articles/heroku-local
[squash]: https://github.com/thoughtbot/guides/tree/master/protocol/git#write-a-feature
