# ---------------------------------------------------------------------------------------------------------------------
# CREATE A VPC TO CONTAIN THE RESOURCES
# ---------------------------------------------------------------------------------------------------------------------

module "vpc" {
  source             = "./modules/network/aws/vpc"
  name               = "${var.project_name}"
  region             = "${var.aws_region}"
  availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

  # An example of custom tags
  tags = [
    {
      Environment = "development"
    },
  ]
}
