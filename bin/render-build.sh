#!/usr/bin/env bash
# Render build script — runs in an isolated build container that does
# NOT have access to the private DB network, so migrations live in
# startCommand (see render.yaml) where the runtime container does.
set -o errexit

bundle install

# assets:precompile triggers javascript:install + javascript:build
# (jsbundling-rails) and tailwindcss:build via task dependencies.
bundle exec rails assets:precompile
