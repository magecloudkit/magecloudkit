# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "vpc_id" {
  description = "The ID of the VPC in which to launch the ElastiCache resources"
}

variable "subnet_ids" {
  type        = "list"
  description = "The IDs of the Subnets in which to launch the ElastiCache resources"
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "cluster_name" {
  description = "The name used for the ElastiCache cluster"
  default     = "redis01"
}

variable "engine" {
  description = "The ElastiCache engine"
  default     = "redis"
}

variable "engine_version" {
  description = "The ElastiCache engine version"
  default     = "3.2.4"
}

variable "node_type" {
  description = "ElastiCache instance type"
  default     = "cache.m3.large"
}

variable "port" {
  description = "ElastiCache Redis port"
  default     = 6379
}

variable "num_cache_nodes" {
  description = "ElastiCache number of cache nodes"
  default     = 1
}

variable "parameter_group_name" {
  description = "ElastiCache Parameter Group Name"
  default     = "default.redis3.2"
}

variable "allowed_inbound_cidr_blocks" {
  description = "A list of CIDR-formatted IP address ranges from which the ElastiCache resources will allow inbound connections."
  type        = "list"
  default     = []
}

variable "allowed_inbound_security_group_ids" {
  description = "A list of security group IDs from which the ElastiCache instances will allow inbound connections."
  type        = "list"
  default     = []
}
