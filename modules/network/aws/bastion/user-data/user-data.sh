#!/bin/bash

set -e

# Send the log output from this script to user-data.log, syslog, and the console
# From: https://alestic.com/2010/12/ec2-user-data-output/
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

function configure_bastion {
    local readonly ssh_port="$1"

    echo "Configuring Bastion Node using SSH port $ssh_port..."

    # update apt packages
    sudo apt-get update
    sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

    # configure networking
    # TODO - remove. We are using NAT gateways now.
    #
    #sudo iptables -t nat -A POSTROUTING -j MASQUERADE
    #echo '1' | sudo tee /proc/sys/net/ipv4/ip_forward

    # harden
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y libpam-cracklib
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y fail2ban

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
