# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These parameters must be supplied when consuming this module.
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The name of the log group."
}

variable "environment" {
  description = "The name of the target environment."
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "enable_logs" {
  description = "Whether to enable logs."
  default = false
}

variable "log_bucket_name" {
  description = "The S3 bucket to store the logs. Required if enable_logs is set to true."
  default = ""
}

variable "log_path_prefix" {
  description = "S3 prefix within the log_bucket_name where the logs are stored."
  default = ""
}

variable "subnets" {
  description = "A list of subnets to associate with the load balancer. e.g. ['subnet-1a2b3c4d','subnet-1a2b3c4e','subnet-1a2b3c4f']"
  type        = "list"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "security_groups" {
  description = "The security groups to attach to the load balancer. e.g. [\"sg-edcd9784\",\"sg-edcd9785\"]"
  type        = "list"
}

variable "target_groups" {
  description = "A list of maps containing key/value pairs that define the target groups to be created. Order of these maps is important and the index of these are to be referenced in listener definitions. Required key/values: name, backend_protocol, backend_port. Optional key/values are in the target_groups_defaults variable."
  type        = "list"
  default     = []
}

variable "target_groups_count" {
  description = "A manually provided count/length of the target_groups list of maps since the list cannot be computed."
  default     = 0
}

variable "target_groups_defaults" {
  description = "Default values for target groups as defined by the list of maps."
  type        = "map"

  default = {
    "cookie_duration"                  = 86400
    "deregistration_delay"             = 300
    "health_check_interval"            = 10
    "health_check_healthy_threshold"   = 3
    "health_check_path"                = "/"
    "health_check_port"                = "traffic-port"
    "health_check_timeout"             = 5
    "health_check_unhealthy_threshold" = 3
    "health_check_matcher"             = "200-299"
    "stickiness_enabled"               = true
    "target_type"                      = "instance"
  }
}

variable "vpc_id" {
  description = "VPC id where the load balancer and other resources will be deployed."
}
