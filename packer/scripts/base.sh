#!/bin/bash

export UCF_FORCE_CONFFOLD=1
export DEBIAN_FRONTEND=noninteractive

apt-get -qy update
apt-get -qy -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' --force-yes upgrade
apt-get -qy -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' --force-yes install ca-certificates curl git gnupg openssl
install -m 0755 -d /etc/apt/keyrings