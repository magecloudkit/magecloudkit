# Jenkins Server

This folder contains a Terraform module to deploy a single instance Jenkins server inside an AWS Auto Scaling Group.
It attaches an EBS volume and uses an ALB load balancer for health checks. The new instances will automatically reattach the same EBS volume in the event of a failure. It requires an AMI that has Jenkins installed, ideally created using the `jenkins-ami` module.

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
