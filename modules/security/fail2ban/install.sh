#!/bin/bash
set -e

# Locate the directory in which this script is located
readonly script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

apt-get install fail2ban
systemctl restart fail2ban

# Execute the install script
#chmod u+x "${script_path}/install-scripts/copy-packer-files.sh"
#eval "${script_path}/install-scripts/copy-packer-files.sh $@"
