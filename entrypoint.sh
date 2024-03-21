#!/bin/bash
set -e

echo 'Waiting for postgres...'

while ! nc -z db 5432; do
  sleep 1
done

echo 'PostgreSQL started'

echo 'Waiting for redis...'

while ! nc -z redis 6379; do
  sleep 1
done

echo 'Redis started'

exec "$@"
