variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "availability_zones" {
  description = "List of availability zones"
  default     = "us-east-1a,us-east-1b,us-east-1c"
}

/* VPC settings */
variable "vpc_cidr" {
  description = "CIDR for VPC"
  default     = "172.31.0.0/16"
}

variable "public_subnet_az1_cidr" {
  description = "CIDR for az1 public subnet"
  default     = "172.31.0.0/24"
}

variable "public_subnet_az2_cidr" {
  description = "CIDR for az2 public subnet"
  default     = "172.31.1.0/24"
}

variable "public_subnet_az3_cidr" {
  description = "CIDR for az3 public subnet"
  default     = "172.31.2.0/24"
}

variable "private_subnet_az1_cidr" {
  description = "CIDR for az1 private subnet"
  default     = "172.31.3.0/24"
}

variable "private_subnet_az2_cidr" {
  description = "CIDR for az2 private subnet"
  default     = "172.31.4.0/24"
}

variable "private_subnet_az3_cidr" {
  description = "CIDR for az3 private subnet"
  default     = "172.31.5.0/24"
}

variable "amazon_dns_server" {
  description = "DNS server that is pushed to the VPN clients"
  default     = "172.31.0.2"
}

/* Ubuntu 16.04 amis by region */
variable "amis" {
  description = "Base AMI to launch the instances with"

  default = {
    eu-west-1    = "ami-6d48500b"
    eu-central-1 = "ami-1c45e273"
    us-east-1    = "ami-e6d5d2f1"
  }
}

variable "ssh_user" {
  description = "SSH user used for provisioning"
  default     = "ubuntu"
}

/* Environment variables passed to docker images */
variable "env_mysql_database" {
  default = "magento2"
}

variable "env_mysql_user" {
  default = "magento2"
}

variable "default_log_account_ids" {
  description = "This is the ID of the IAM principal for ELB/ALB. It is used to let LBs write logs to S3 buckets."

  default = {
    us-east-1      = "127311923021"
    us-west-2      = "797873946194"
    us-west-1      = "027434742980"
    eu-west-1      = "156460612806"
    eu-central-1   = "054676820928"
    ap-southeast-1 = "114774131450"
    ap-northeast-1 = "582318560864"
    ap-southeast-2 = "783225319266"
    ap-northeast-2 = "600734575887"
    sa-east-1      = "507241528517"
    us-gov-west-1  = "048591011584"
    cn-north-1     = "638102146993"
  }
}
