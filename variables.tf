# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "project_name" {
  description = "The project name used to tag resources."
  default     = "magecloudkit-development"
}

variable "environment" {
  description = "The environment used to tag resources."
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

variable "availability_zones" {
  description = "List of availability zones."
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "ecs_ami" {
  description = "The ECS AMI used to run . This AMI is built from the ECS-AMI Packer template (See modules/app-cluster/aws/ecs-ami/ecs.json)."
  default     = "ami-0be2dee98c4f5afda"
}

variable "ecs_cluster_name" {
  description = "The ECS Cluster Name."
  default     = "development-app"
}

variable "key_pair_name" {
  description = "The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this VPC. Set to an empty string to not associate a Key Pair."
  default     = "robs-2017-mbp"
}

variable "jenkins_load_balancer_port" {
  description = "The port the load balancer should listen on for Jenkins Web UI requests."
  default     = 8080
}
