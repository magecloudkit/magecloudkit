# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  type        = "string"
  description = "A preferably short unique identifier for this module"
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters are preconfigured and have reasonable default values.
# ---------------------------------------------------------------------------------------------------------------------

variable "retention_in_days" {
  description = "The number of days for log retention. We recommend a value greater than 7."
  default     = 30
}
