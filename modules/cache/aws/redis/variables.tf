# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "vpc_id" {
  description = "The ID of the VPC in which to launch the ElastiCache instance."
}

variable "subnet_id" {
  description = "The ID of the Subnet in which to launch the ElastiCache instance."
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "cluster_id" {
  description = "The name used for the Redis cluster id"
  default     = "redis-production"
}

variable "engine" {
  description = "The name used for the ElastiCache engine"
  default     = "redis"
}

variable "engine_version" {
  description = "The name used for the ElastiCache engine"
  default     = "3.2.4"
}

variable "node_type" {
  description = "node_type ElastiCache instance"
  default     = "cache.t2.small"
}

variable "port" {
  description = "ElastiCache instance port"
  default     = 6379
}

variable "num_cache_nodes" {
  description = "ElastiCache number of cache nodes"
  default     = 1
}

variable "parameter_group_name" {
  description = "ElastiCache number of cache nodes"
  default     = "default.redis3.2"
}

# ---------------------------------------------------------------------------------------------------------------------
# SUBNET GROUP VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "subnet_group_name" {
  description = "The name used for the Redis subnet group"
  default     = "redis-production-subnet"
}

variable "subnet_group_description" {
  description = "Description of Redis subnet group"
  default     = ""
}

# ---------------------------------------------------------------------------------------------------------------------
# SECURITY GROUP VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "security_group_name" {
  description = "The name used for the Redis subnet group"
  default     = "sg_production_redis"
}

variable "security_group_description" {
  description = "Description of Redis security group"
  default     = "Security group for the Redis servers"
}

variable "redis_port" {
  description = "ElastiCache security group ingress/outgress port"
  default     = 6379
}
