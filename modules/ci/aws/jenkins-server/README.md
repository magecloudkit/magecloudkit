# Jenkins Server

This folder contains a Terraform module to deploy a single instance Jenkins server inside an AWS Auto Scaling Group.
It uses an EFS filesystem to store data an ALB load balancer for health checks. New instances will automatically
reattach the same EFS filesysten in the event of a failure. It requires an AMI that has Jenkins installed, ideally
created using the `jenkins-ami` module.

Please read [Deploying Jenkins on AWS](https://docs.aws.amazon.com/aws-technical-content/latest/jenkins-on-aws/deploying-jenkins-on-aws.html) for more information.

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
