# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These parameters must be supplied when consuming this module.
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The name of the service"
}

variable "cluster_name" {
  description = "The name of the cluster in which the service will be deployed"
}

variable "container_name" {
  description = ""
}

variable "container_port" {
  description = ""
}

variable "target_group_arn" {
  description = ""
}

variable "task_definition" {
  description = "The ARN of the task definition to be deployed on top of this service."
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "cluster_arn" {
  description = "The arn of the ECS cluster in which the service will be deployed"
}

variable "ecs_service_iam_role_arn" {
  description = ""
  default     = ""
}

variable "desired_task_count" {
  description = "The desired number of tasks to run on top of this service."
  default     = "1"
}

variable "enable_autoscaling" {
  description = "Whether or not to enable ECS task based Autoscaling."
  default     = false
}

variable "desired_min_capacity" {
  description = "The minimum amount of ECS tasks to run when scaling down."
  default     = "1"
}

variable "desired_max_capacity" {
  description = "The maximum amount of ECS tasks to run when scaling up."
  default     = "1"
}

variable "autoscaling_properties" {
  description = "A list of Autoscaling properties to apply to the ECS tasks."
  type        = "list"
  default     = []
}

# Internal lookup map
variable "autoscaling_direction" {
  type = "map"

  default = {
    up   = ["GreaterThanOrEqualToThreshold", "scale_out"]
    down = ["LessThanThreshold", "scale_in"]
  }
}

variable "deployment_maximum_percent" {
  description = ""
  default     = 200
}

variable "deployment_minimum_healthy_percent" {
  description = ""
  default     = 100
}

variable "container_definitions" {
  description = ""
  default     = ""
}

variable "allowed_security_group_ids" {
  description = "A list of Security Group IDs."
  type        = "list"
  default     = []
}
