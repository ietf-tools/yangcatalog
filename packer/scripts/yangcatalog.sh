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
mkdir -p /app/frontend/yangcatalog-ui/tmp

# Copy files

cp /var/yang/confd-8.0.linux.x86_64.installer.bin ./resources/confd-8.0.linux.x86_64.installer.bin
chmod 777 ./resources/confd-8.0.linux.x86_64.installer.bin

cp /var/yang/yumapro-client-21.10-12.deb11.amd64.deb ./resources/yumapro-client-21.10-12.deb11.amd64.deb

cp /var/yang/pt-topology-0.1.0.tgz ./frontend/yangcatalog-ui/tmp/pt-topology-0.1.0.tgz

# Start containers
docker compose build
# docker compose up