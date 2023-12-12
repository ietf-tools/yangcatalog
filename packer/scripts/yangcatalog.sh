#!/bin/bash

mkdir /app
cd /app

# Fetch Yang Catalog project
git clone --depth 1 https://github.com/YangCatalog/deployment.git .
git submodule update --init
mv .env-dist .env

# Create directories
mkdir -p /etc/yangcatalog
mkdir -p /var/yang
mkdir -p /var/yang/logs/confd
mkdir -p /var/yang/logs/opensearch
mkdir -p /var/yang/logs/nginx
mkdir -p /var/yang/opensearch
mkdir -p /var/yang/redis

# Start containers
docker compose build
# docker compose up