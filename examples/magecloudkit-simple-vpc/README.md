# MageCloudKit Simple VPC Example

This folder contains an example of how to deploy a simple MageCloudKit architecture inside an Amazon VPC.

## Features

 * Bastion node for secure SSH access
 * 1 x ALB Load Balancer

## Usage

To deploy this example:

1. `git clone` this repository your computer.
1. Optional: build a custom MageCloudKit App Ami. See the `app-cluster/aws/ecs-ami` module. Make sure to note down the ID of the AMI.
1. Install [Terraform](https://www.terraform.io/).
1. Open the `variables.tf` file in the root of this repository, set the environment variables specified at the top of the
   file, and fill in any other variables that don't have a default. If you built a custom AMI, put its ID into the
   `ami_id` variable. If you didn't, this example will use public AMIs that Brightfame has published, which are fine for
   testing/learning, but not recommended for production use.
1. Run `terraform init` in the root folder of this repository.
1. Run `terraform apply` in the root folder of this repository.

**Note:** launching a new MageCloudKit architecture can take 5 - 10 minutes, depending on the number and types of instances.
