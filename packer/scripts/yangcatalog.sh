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

# Copy files
cp /var/yang/confd-8.0.linux.x86_64.installer.bin ./confd/resources/confd-8.0.linux.x86_64.installer.bin
cp /var/yang/confd-8.0.linux.x86_64.installer.bin ./module-compilation/confd-8.0.linux.x86_64.installer.bin
cp /var/yang/confd-8.0.linux.x86_64.installer.bin ./yang-validator-extractor/resources/confd-8.0.linux.x86_64.installer.bin
cp /var/yang/yumapro-client-21.10-12.deb11.amd64.deb ./yang-validator-extractor/resources/yumapro-client-21.10-12.deb11.amd64.deb

# Start containers
docker compose build
# docker compose up