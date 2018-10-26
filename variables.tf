# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "project_name" {
  description = "The project name used to tag resources."
  default     = "magecloudkit-production"
}

variable "environment" {
  description = "The environment used to tag resources."
  default     = "production"
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "aws_region" {
  description = "The AWS region to create resources in."
  default     = "us-west-1"
}

variable "availability_zones" {
  description = "List of availability zones."
  default     = ["us-west-1a", "us-west-1c"]
}

variable "internal_domain" {
  description = "The internal domain used for service discovery."
  default     = "magecloudkit.internal"
}

variable "ecs_ami" {
  description = "The ECS AMI used to run our ECS cluster instances. This AMI is built from the ECS-AMI Packer template (See the KiwiCo customized version: kiwico/ecs-ami/ecs.json)."
  default     = "ami-0e8d1356ecdcca81d"
}

variable "ecs_cluster_name_app" {
  description = "The ECS cluster name for running the Magento web, checkout and api services."
  default     = "production-app"
}

variable "ecs_cluster_name_admin" {
  description = "The ECS cluster name for running the Magento admin service."
  default     = "production-admin"
}

variable "ecs_cluster_name_checkout" {
  description = "The ECS cluster name for running the Magento checkout service."
  default     = "production-checkout"
}

variable "key_pair_name" {
  description = "The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this VPC. Set to an empty string to not associate a Key Pair."
  default     = "robs-2017-mbp"
}

variable "jenkins_ami" {
  description = "The AMI used to run our Jenkins instance. This AMI is built from the Jenkins-AMI Packer template (See the KiwiCo customized version: kiwico/jenkins-ami/jenkins.json)."
  default     = "ami-0a572ed47a73e25e2"
}

variable "jenkins_http_port" {
  description = "The port to use for the Jenkins HTTP Web UI."
  default     = 8080
}

variable "env_mysql_database" {
  description = "The MySQL database used by Magento."
  default     = "magento2"
}

variable "env_mysql_user" {
  description = "The MySQL user used by Magento."
  default     = "magento2"
}

variable "env_mysql_password" {
  description = "The MySQL password used by Magento."
  default     = "production"
}

variable "env_mage_table_prefix" {
  description = "The MySQL table prefix used by Magento."
  default     = "magento_"
}

variable "env_blackfire_server_id" {
  description = "The Server Id used by Blackfire.io."
  default     = "852036a8-a5ed-44e0-b02a-36e575a5cddb"
}

variable "env_blackfire_server_token" {
  description = "The Server Token used by Blackfire.io."
  default     = "35a7ee2b9a06b34d1aaeebd7c513c74630de9be74eacb49c4d8f50b19670393d"
}
