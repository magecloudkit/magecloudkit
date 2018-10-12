# ---------------------------------------------------------------------------------------------------------------------
# CREATE A VPC TO CONTAIN THE RESOURCES
# ---------------------------------------------------------------------------------------------------------------------

module "vpc" {
  source             = "./modules/network/aws/vpc"
  name               = "${var.project_name}"
  region             = "${var.aws_region}"
  availability_zones = "${var.availability_zones}"

  # An example of custom tags
  tags = [
    {
      Environment = "${var.environment}"
    },
  ]
}
