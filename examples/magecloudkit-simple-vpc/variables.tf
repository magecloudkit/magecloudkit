# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "project_name" {
  description = "The project name used when naming resources."
  default     = "magecloudkit-development"
}

variable "environment" {
  description = "The environment used when naming resources."
  default     = "development"
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "aws_region" {
  description = "The AWS region to create resources in."
  default     = "eu-west-1"
}

variable "ecs_cluster_name" {
  description = "The ECS Cluster Name."
  default     = "development-app"
}

variable "key_pair_name" {
  description = "The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this VPC. Set to an empty string to not associate a Key Pair."
  default     = ""
}

variable "internal_domain" {
  description = "The internal domain used for Route 53 service discovery."
  default     = "magecloudkit.internal"
}

variable "jenkins_ami" {
  description = ""
  default     = ""
}

variable "jenkins_load_balancer_port" {
  description = "The port the load balancer should listen on for Jenkins Web UI requests."
  default     = 8080
}

variable "media_volume_mount_point" {
  description = "The path where we should mount the EFS filesystem used for Magento media assets on the EC2 instances."
  default     = "/mnt/media"
}
