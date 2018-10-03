# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "ami_id" {
  description = "The ID of the Jenkins AMI to run in the ASG. This should be an AMI built from the Jenkins AMI module under modules/ci/jenkins-ami."
}

variable "jenkins_cluster_name" {
  description = "The name of the Jenkins Auto Scaling Group (e.g. jenkins-production)."
  default = "jenkins-production"
}

variable "data_volume_device_name" {
  description = "The device name to use for the EBS Volume used for the Jenkins data directory."
  default     = "/dev/xvdh"
}

variable "data_volume_mount_point" {
  description = "The mount point (folder path) to use for the EBS Volume used for the Jenkins data directory."
  default     = "/jenkins-data"
}

variable "volume_owner" {
  description = "The OS user who should be made the owner of the data volume mount point."
  default     = "jenkins"
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "ssh_key_name" {
  description = "The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this VPC. Set to an empty string to not associate a Key Pair."
  default     = "rob-mbp2017"
}

variable "jenkins_load_balancer_port" {
  description = "The port the load balancer should listen on for Jenkins Web UI requests."
  default     = 8080
}
