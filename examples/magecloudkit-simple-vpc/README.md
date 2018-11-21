# MageCloudKit Simple VPC Example

This folder contains an example of how to deploy a simple MageCloudKit architecture inside an Amazon VPC.

The included task definition deploys Nginx and Magento 2.2.

## Features

 * Bastion node for secure SSH access
 * 1 x ALB Load Balancer

## Usage

To deploy this example:

1. `git clone` this repository your computer.
2. Install [Terraform](https://www.terraform.io/).
3. Open the `variables.tf` file, set the environment variables specified at the top of the file, and fill in any other variables that don't have a default.
4. Copy the `terraform.tfvars.example` file to `terraform.tfvars` and change the defaults.
5. Run `terraform init` from this folder.
6. Run `terraform plan` from this folder.
7. Run `terraform apply` from this folder.

**Note:** Launching a new MageCloudKit architecture can take 5 - 10 minutes, depending on the number and types of instances.
