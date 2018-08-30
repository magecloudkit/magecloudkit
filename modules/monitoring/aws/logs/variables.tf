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

variable "retention_in_days" {
  description = "The number of days for log retention. We recommend a value greater than 7."
  default = 30
}
