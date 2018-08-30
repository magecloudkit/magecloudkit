#!/bin/bash
set -xe

systemctl daemon-reload
systemctl enable bootstrap.service
systemctl enable setup-network-environment.service
systemctl enable efs-media-mount.service
