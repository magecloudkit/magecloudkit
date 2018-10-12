# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "cluster_identifier" {
  description = "The identifier for the RDS cluster"
}

variable "cluster_instance_prefix" {
  description = "A prefix used to identify RDS Cluster instances."
}

variable "vpc_id" {
  description = "The ID of the VPC in which to launch the RDS resources"
}

variable "subnet_ids" {
  type        = "list"
  description = "The IDs of the Subnets in which to launch the RDS resources"
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "database_name" {
  description = "The database name"
  default     = "magento2"
}

variable "master_username" {
  description = "The RDS database master username"
  default     = "magento2"
}

variable "master_password" {
  description = "RDS password"
  default     = "magento2"
}

variable "backup_retention_period" {
  description = "RDS backup retention period"
  default     = 7
}

variable "preferred_backup_window" {
  description = "RDS preferred backup window"
  default     = "01:00-02:00"
}

variable "cluster_instance_count" {
  description = "AWS RDS Cluster instance count"
  default     = 2
}

variable "engine" {
  description = "The name of the database engine to be used for the RDS instance. Valid Values: aurora, aurora-mysql, aurora-postgresql."
  default     = "aurora-mysql"
}

variable "engine_version" {
  description = "The database engine version."
  default     = "5.7.12"
}

variable "instance_class" {
  description = "AWS RDS instance class"
  default     = "db.t2.medium"
}

variable "port" {
  description = "RDS ingress port"
  default     = 3306
}

variable "egress_port" {
  description = "RDS egress port"
  default     = 0
}
