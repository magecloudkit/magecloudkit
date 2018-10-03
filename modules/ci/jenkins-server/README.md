# Jenkins Server

This folder contains a Terraform module to deploy a single instance Jenkins server inside an AWS Autoscaling group.
It attaches an EBS volume and uses Route 53 for DNS. It requires an AMI that has Jenkins installed, ideally created using the `jenkins-ami` module.

## Usage

You can use this code by adding a module configuration and setting its `source` parameter to the URL of this folder:

```hcl
module "jenkins_server" {
  # ... See variables.tf for the other parameters you must define for this module
}
```

## What's included in this module?

 * Autoscaling Group
 * EBS Volume
 * Security Group
 * IAM Role & Permissions
