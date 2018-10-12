# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These parameters must be supplied when consuming this module.
# ---------------------------------------------------------------------------------------------------------------------

variable "service_name" {
  description = "The name of the service"
}

variable "cluster" {
  description = "The name of the cluster in which the service will be deployed"
}

variable "vpc_id" {
  description = "The ID of the VPC in which to launch the RDS resources"
}

variable "environment" {
  description = "The name of the target environment."
}

variable "subnet_ids" {
  type        = "list"
  description = "The IDs of the Subnets in which to launch the RDS resources"
}

variable "task_definition" {
  description = "The task definition to be deployed on top of this service."
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "desired_count" {
  description = "The task count to be deployed on top of this service."
  default     = "2"
}

variable "aws_alb_name" {
  description = "The AWS ALB name"
  default     = "production-aws-alb"
}

variable "aws_alb_access_logs_bucket" {
  description = "The AWS ALB Access logs bucket"
  default     = "production-aws-alb-bucket"
}
