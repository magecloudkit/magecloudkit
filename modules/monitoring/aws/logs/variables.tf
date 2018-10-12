# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These parameters must be supplied when consuming this module.
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The name of the log group."
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "retention_in_days" {
  description = "The number of days for log retention. We recommend a value greater than 7."
  default     = 30
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
