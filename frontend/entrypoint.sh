#!/bin/sh
set -e

: "${BACKEND_BASE_URL:=http://backend:5000}"

# Substitute env var into nginx config
envsubst '${BACKEND_BASE_URL}' < /etc/nginx/templates/nginx.conf.template > /etc/nginx/nginx.conf

exec nginx -g 'daemon off;'
