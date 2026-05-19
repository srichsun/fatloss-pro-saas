#!/usr/bin/env bash
# Render build script — runs during deploy.
set -o errexit

bundle install
yarn install --frozen-lockfile

# assets:precompile triggers javascript:build (esbuild) and
# tailwindcss:build via task dependencies wired up by the gems.
bundle exec rails assets:precompile

# db:prepare creates the database if needed, then runs migrations
# for every configured connection (primary, cache, queue, cable).
bundle exec rails db:prepare
