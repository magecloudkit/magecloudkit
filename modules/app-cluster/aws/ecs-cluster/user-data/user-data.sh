#!/bin/bash
set -Eeuxo pipefail

# Variables interpolated from Terraform.

# Environment
echo "ECS_CLUSTER=${cluster_name}" >> /etc/ecs/ecs.config
echo "AWS_DEFAULT_REGION=${aws_region}" >> /etc/environment
echo "ENVIRONMENT=${environment}" >> /etc/environment

# Add the ECS agent iptables rules
if [ "${block_metadata_service}" == "1" ]; then
 echo 'while ! iptables -L DOCKER-USER > /dev/null 2>/dev/null ; do echo "Waiting for the iptables DOCKER-USER chain to exist";sleep 1;done' >> /etc/rc.local
 echo iptables --insert DOCKER-USER 1 --in-interface docker+ --destination 169.254.169.254/32 --jump DROP >> /etc/rc.local
fi

# Mount the EFS filesystem
if [ "${enable_efs}" == "1" ]; then
  mkdir ${efs_mount_point}
  if ! rpm -qa | grep -qw amazon-efs-utils; then
    yum -y install amazon-efs-utils
  fi
  if ! rpm -qa | grep -qw python27; then
	  yum -y install python27
  fi

  DIR_TGT=${efs_mount_point}/

  mount -t efs ${efs_file_system_id} $DIR_TGT
  cp -p /etc/fstab /etc/fstab.back-$(date +%F)
  # Append line to fstab
  echo -e "${efs_file_system_id} \t\t $DIR_TGT \t\t efs \t\t _netdev \t\t 0 \t\t 0" | tee -a /etc/fstab
fi
