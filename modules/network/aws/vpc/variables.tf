/**
 * Required Variables.
 *
 * A value for these variables must be set when invoking the module.
 */
variable "availability_zones" {
  description = "List of availability zones"
  type        = "list"
}

variable "environment" {
  description = "The environment (production, staging, qa)."
}

/**
 * Optional Variables.
 *
 * These variables are preconfigured and have acceptable default values.
 */
variable "name" {
  description = "The VPC name. Used when setting tags on resources."
  default     = "stack"
}

variable "cidr" {
  description = "The VPC CIDR."
  default     = "172.31.0.0/16"
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames."
  default     = true
}

variable "ami_id" {
  description = "The ID of the AMI to run. The value should be an Ubuntu 16.04 AMI for your given AWS region. Leave blank to default to the latest public Ubuntu 16.04 AMI from Canonical."
  default     = ""
}

variable "description" {
  description = "Description of VPC"
  default     = ""
}

// dhcp settings
// Ref: https://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_DHCP_Options.html
domain-name-servers
domain-name
ec2.internal for us-east-1 or region.compute.internal for other regions
