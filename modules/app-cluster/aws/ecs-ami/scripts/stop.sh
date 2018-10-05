#!/bin/bash
set -e

if [ "$(ls -A /tmp/root)" ]
then
  cd /tmp/root
  cp -r * /
fi

systemctl daemon-reload

apt-get -y autoremove
apt-get -y autoclean

rm -rf /tmp/*
rm -rf /var/tmp/*
#rm -rf $HOME/.ssh/authorized_keys

for f in $(find /var/log -type f) ; do
  dd if=/dev/null of=$f
done
