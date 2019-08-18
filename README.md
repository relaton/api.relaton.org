# Relaton Service (relaton.org)

## Getting Started

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
