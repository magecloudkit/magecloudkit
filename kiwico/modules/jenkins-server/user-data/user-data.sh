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

  echo "Creating Mount Point $mount_point"
  mkdir -p "$mount_point"

  echo "Adding EFS filesystem $efs_filesystem_id to /etc/fstab with mount point $mount_point"
  echo "$efs_filesystem_id    $mount_point   $file_system_type    $mount_options  0 0" >> "$fs_tab_path"

  echo "Mounting volume..."
  mount "$mount_point"

  echo "Changing ownership of $mount_point to $owner..."
  chown "$owner" "$mount_point"
}

function create_symlink {
  local readonly source="$1"
  local readonly target="$2"

  echo "Creating symlink from: $source to: $target"

  if [[ -L "$target" && -d "$target" ]]
  then
      echo "The directory symlink already exists: $target"
  else
      ln -nsf $source $target
  fi
}

function create_symlinks {
  echo "Creating symlinks"
  create_symlink "/mnt/media/magento" "/mnt/jenkins/workspace/git_checkout/media"
  create_symlink "/mnt/media/shared" "/mnt/jenkins/workspace/git_checkout/shared"
  # TODO this can be removed in the future
  mkdir -p /home/kiwi
  create_symlink "/mnt/media/shared" "/home/kiwi/shared"
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

function add_environment_vars {
  echo "Adding custom env vars to /etc/environment"
  echo "KIWI_SHARED_DIR=/mnt/media/shared" >> /etc/environment
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
  create_symlinks
  update_jenkins_home "$data_volume_mount_point"
  add_environment_vars
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
