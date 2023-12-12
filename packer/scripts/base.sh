#!/bin/bash

sudo apt-get -qy update
sudo apt-get -qy -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' upgrade
sudo apt-get -qy -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' --force-yes install ca-certificates curl git gnupg openssl
sudo install -m 0755 -d /etc/apt/keyrings