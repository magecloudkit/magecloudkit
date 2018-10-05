#!/bin/bash

#Variables interpolated from terraform.

# Environment
echo "SERVER_GROUP=${cluster}" >> /etc/environment

echo "AWS_DEFAULT_REGION=${aws_region}" >> /etc/environment
echo "ENVIRONMENT=${environment}" >> /etc/environment

echo "MYSQL_HOST=${mysql_host}" >> /etc/environment
echo "MYSQL_DATABASE=${mysql_database}" >> /etc/environment
echo "MYSQL_USER=${mysql_user}" >> /etc/environment
echo "MYSQL_PASSWORD=${mysql_password}" >> /etc/environment

# restart docker and the ecs-agent to pickup the env vars
systemctl restart docker.service
systemctl restart ecs-agent.service
