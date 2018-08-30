/**
 * Required Variables.
 */
variable "name" {
  description = "The cron name"
}

variable "environment" {
  description = "The environment"
}

/**
 * Optional Variables.
 */
variable "description" {
  description = "Description of instance"
  default     = ""
}
