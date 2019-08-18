#!/usr/bin/env bash

wait-for-it db:5432 &&
rm -f /relaton.org/tmp/pids/server.pid &&
bundle exec rails server --port 3000 --binding 0.0.0.0
