#!/bin/bash
set -e

if [ "$(ls -A /tmp/root)" ]
then
  cd /tmp/root
  cp -r * /
fi

systemctl daemon-reload
