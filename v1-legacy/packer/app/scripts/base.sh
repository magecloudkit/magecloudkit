#!/bin/bash
set -e

systemctl disable apt-daily.service
systemctl disable apt-daily.timer

apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

# Stop debconf from asking interactive questions by pre-seeding the config
#echo iptables-persistent	iptables-persistent/autosave_v6	boolean	false | sudo debconf-set-selections -v
#echo iptables-persistent	iptables-persistent/autosave_v4	boolean	false | sudo debconf-set-selections -v

apt-get install -y \
        build-essential  \
        git-core \
        dkms \
        wget \
        curl \
        unzip \
        vim \
        curl \
        htop \
        nfs-common \
        make \
        logrotate \
        python3-apt \
        python3-pip \
        jq

ln -s /usr/bin/pip3 /usr/bin/pip
pip install --upgrade pip
pip install --upgrade --user awscli
