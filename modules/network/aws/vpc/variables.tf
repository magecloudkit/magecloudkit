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
  description = "The VPC CIDR block"
  default     = "172.31.0.0/16"
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames"
  default     = true
}

variable "enable_dhcp" {
  description = "Enable the DHCP options"
  default     = false
}

variable "dhcp_domain_name" {
  description = "DHCP domain name"
  default     = "magecloudkit.internal"
}

variable "dhcp_domain_name_servers" {
  description = "DHCP domain name servers"
  default     = []
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
  description = "A map of extra tag blocks added to the resources. Each element in this map is a key/value pair mapped to the respective values."
  type        = "map"
  default     = {}

  # Example:
  #
  # default = {
  #   key = "value"
  # }
}
