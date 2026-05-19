#!/usr/bin/env bash
# Render build script — runs during deploy.
set -o errexit

bundle install

# assets:precompile triggers javascript:install + javascript:build
# (jsbundling-rails) and tailwindcss:build via task dependencies.
# We don't run yarn/npm install separately because the chain handles it.
bundle exec rails assets:precompile

# db:prepare creates the database if needed, then runs migrations
# for every configured connection (primary, cache, queue, cable).
bundle exec rails db:prepare
