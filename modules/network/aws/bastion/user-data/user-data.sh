#!/bin/bash

set -e

# Send the log output from this script to user-data.log, syslog, and the console
# From: https://alestic.com/2010/12/ec2-user-data-output/
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

function configure_bastion {
    local readonly ssh_port="$1"

    echo "Configuring Bastion Node using SSH port $ssh_port..."

    # TODO - configure alternate SSH port and update Fail2ban jail.
    # automatic update script will run after
    # fail2ban install script will run after
    echo "Done."
}

function run {
  # TODO - support SSH port configuration
  local readonly ssh_port="$1"

  configure_bastion "$ssh_port"
}

# The variables below are filled in via Terraform interpolation
run \
  "${ssh_port}"
