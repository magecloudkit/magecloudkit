#!/bin/bash

set -e

# Send the log output from this script to user-data.log, syslog, and the console
# From: https://alestic.com/2010/12/ec2-user-data-output/
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

function mount_volume {
  local readonly efs_filesystem_id="$1"
  local readonly mount_point="$2"
  local readonly owner="$3"
  local readonly file_system_type="efs"
  local readonly mount_options="defaults,_netdev"
  local readonly fs_tab_path="/etc/fstab"

  echo "Mounting EFS filesystem for the data directory"
  mkdir -p "$mount_point"

  echo "Adding EFS filesystem $efs_filesystem_id to /etc/fstab with mount point $mount_point"
  echo "$efs_filesystem_id    $mount_point   $file_system_type    $mount_options  0 0" >> "$fs_tab_path"

  echo "Mounting volumes..."
  mount -a

  echo "Changing ownership of $mount_point to $owner..."
  chown "$owner" "$mount_point"
}

function update_jenkins_home {
  local readonly data_volume_mount_point="$1"

  echo "Stopping Jenkins"
  systemctl stop jenkins

  # We need to copy the Jenkins data files if its the first time mounting the volume
  if [ ! -f $data_volume_mount_point/config.xml ]; then
    echo "Copying Jenkins data files"
    rsync -a /var/lib/jenkins/ $data_volume_mount_point
  fi

  echo "Updating JENKINS_HOME"
  sed -i.bak "s@JENKINS_HOME=/var/lib/\$$NAME@JENKINS_HOME=$data_volume_mount_point@g" /etc/default/jenkins
}

function run_jenkins {
  local readonly http_port="$1"
  local readonly data_dir="$2"

  echo "Starting Jenkins"
  systemctl restart jenkins
}

function run {
  # TODO - support HTTP port configuration
  local readonly http_port="$1"
  local readonly jenkins_efs_filesystem_id="$2"
  local readonly media_efs_filesystem_id="$3"
  local readonly data_volume_mount_point="$4"
  local readonly media_volume_mount_point="$5"
  local readonly volume_owner="$6"

  mount_volume "$jenkins_efs_filesystem_id" "$data_volume_mount_point" "$volume_owner"
  mount_volume "$media_efs_filesystem_id" "$media_volume_mount_point" "$volume_owner"
  update_jenkins_home "$data_volume_mount_point"
  run_jenkins "$http_port" "$data_volume_mount_point"
}

# The variables below are filled in via Terraform interpolation
run \
  "${http_port}" \
  "${jenkins_efs_filesystem_id}" \
  "${media_efs_filesystem_id}" \
  "${data_volume_mount_point}" \
  "${media_volume_mount_point}" \
  "${volume_owner}"
