#!/usr/bin/env bash
set -e

# Brightfame Auto Update Module
#
# This script is designed to be run as root.

# Install dependencies
echo "Configuring system for automatic updates..."
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends unattended-upgrades
sudo DEBIAN_FRONTEND=noninteractive dpkg-reconfigure --priority=low unattended-upgrades

# Generate a random sleep value
RANDOMSLEEP=$(shuf -i 600-1800 -n 1)

# Write the auto update configuration
#
# Destination: /etc/apt/apt.conf.d/20auto-upgrades
# or /etc/apt/apt.conf.d/10periodic
FILEPATH="/etc/apt/apt.conf.d/10periodic"
sudo tee $FILEPATH > /dev/null <<BFEOF
APT::Periodic::Update-Package-Lists "1";

APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";

APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::RandomSleep "$RANDOMSLEEP";
BFEOF

# Write the update distribution channels
#
# Destination: /etc/apt/apt.conf.d/50unattended-upgrades
FILEPATH="/etc/apt/apt.conf.d/50unattended-upgrades"
sudo tee $FILEPATH > /dev/null <<"BFEOF"
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}";
    "${distro_id}:${distro_codename}-security";
    "${distro_id}ESM:${distro_codename}";
    //"${distro_id}:${distro_codename}-updates";
};
BFEOF
