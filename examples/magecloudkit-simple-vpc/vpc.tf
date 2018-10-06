# ---------------------------------------------------------------------------------------------------------------------
# CREATE A VPC TO CONTAIN THE RESOURCES
# ---------------------------------------------------------------------------------------------------------------------

module "vpc" {
  source             = "../../modules/network/aws/vpc"
  name               = "${var.project_name}"
  region             = "${var.aws_region}"
  availability_zones = "${data.aws_availability_zones.available.names}"

  # An example of custom tags
  tags = [
    {
      Environment = "development"
    },
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# GET AVAILABILITY ZONES
# As availability zones differ between AWS accounts, we need to check what's available for the given region.
# ---------------------------------------------------------------------------------------------------------------------

data "aws_availability_zones" "available" {
  state = "available"
}
