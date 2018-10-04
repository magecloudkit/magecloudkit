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
  description = "The name used for the Memcached cluster id"
  default     = "memcached-production"
}

variable "engine" {
  description = "The engine used for the ElastiCache engine"
  default     = "memcached"
}

variable "engine_version" {
  description = "The engine version used for the ElastiCache memcached engine"
  default     = "1.4.24"
}

variable "node_type" {
  description = "node_type ElastiCache instance"
  default     = "cache.m3.large"
}

variable "port" {
  description = "ElastiCache memcached instance port"
  default     = 11211
}

variable "num_cache_nodes" {
  description = "ElastiCache number of cache nodes"
  default     = 1
}

variable "parameter_group_name" {
  description = "ElastiCache number of cache nodes"
  default     = "default.memcached1.4"
}

# ---------------------------------------------------------------------------------------------------------------------
# SUBNET GROUP VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "subnet_group_name" {
  description = "The name used for the  subnet group"
  default     = "memcached-production-subnet"
}

variable "subnet_group_description" {
  description = "Description of Memcached subnet group"
  default     = ""
}

# ---------------------------------------------------------------------------------------------------------------------
# SECURITY GROUP VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "security_group_name" {
  description = "The name used for the Memcached subnet group"
  default     = "sg_production_memcached"
}

variable "security_group_description" {
  description = "Description of Memcached security group"
  default     = "Security group for the Memcached servers"
}

variable "memcached_port" {
  description = "ElastiCache security group ingress/outgress port"
  default     = 11211
}
