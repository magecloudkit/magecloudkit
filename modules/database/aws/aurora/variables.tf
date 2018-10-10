# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

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

variable "cluster_identifier" {
  description = "The identifier for the RDS cluster"
  default     = "rds-prod-aurora-cluster"
}

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
  default     = "production"
}

variable "backup_retention_period" {
  description = "RDS backup retention period"
  default     = 7
}

variable "preferred_backup_window" {
  description = "RDS preferred backup window"
  default     = "01:00-02:00"
}

variable "aws_rds_cluster_instance_count" {
  description = "AWS RDS Cluster instance count"
  default     = 2
}

variable "aws_rds_cluster_instance_identifier" {
  description = "AWS RDS Cluster instance identifier"
  default     = "rds-prod-aurora-cluster-2"
}

variable "instance_class" {
  description = "AWS RDS instance class"
  default     = "db.t2.medium"
}

variable "aws_security_group_name" {
  description = "AWS RDS Security Group Name"
  default     = "sg_prod_rds"
}

variable "port" {
  description = "RDS ingress port"
  default     = 3306
}

variable "egress_port" {
  description = "RDS egress port"
  default     = 0
}

variable "aws_db_subnet_group_name" {
  description = "AWS DB Subnet group name"
  default     = "aurora-prod-default-subnet-group"
}

variable "aws_db_subnet_group_description" {
  description = "AWS DB Subnet group description"
  default     = "Production RDS Aurora Subnets"
}
