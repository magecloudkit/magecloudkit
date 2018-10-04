# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "region" {
  description = "The AWS region"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = "list"
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters are preconfigured and have reasonable default values.
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The name used for the VPC"
  default     = "magecloudkit-default"
}

variable "vpc_cidr" {
  description = "The VPC CIDR."
  default     = "172.31.0.0/16"
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames."
  default     = true
}

variable "public_subnets" {
  description = "List of public subnets"
  type        = "list"
  default     = ["172.31.0.0/24", "172.31.1.0/24", "172.31.2.0/24"]
}

variable "private_subnets" {
  description = "List of private subnets"
  type        = "list"
  default     = ["172.31.3.0/24", "172.31.4.0/24", "172.31.5.0/24"]
}

variable "persistence_subnets" {
  description = "List of persistence subnets"
  type        = "list"
  default     = ["172.31.6.0/24", "172.31.7.0/24", "172.31.8.0/24"]
}

variable "tags" {
  description = "List fo extra tag blocks added to the autoscaling group configuration. Each element in the list is a map containing keys 'key', 'value', and 'propagate_at_launch' mapped to the respective values."
  type        = "map"
  default     = {}

  # Example:
  #
  # default = {
  #   key = "value"
  # }
}
