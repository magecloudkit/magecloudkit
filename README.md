# MageCloudKit PoC

This repository serves as placeholder for the next version of MageCloudKit.

## v2 Design Goals

 * Remove the concept of environments. We'll leave this up to the customer to define which environments they want to use.
 * In reference to the point above, don't have any references to Terraform workspaces.
 * All logic should be encapsulated in modules where-ever possible. This will allow our customers to build custom architectures that suit their specific requirements.
 * A module may consist of Terraform, Packer, Bash, Python or Go code.
 * Be sure to run `terraform fmt` on all Terraform code and `packer validate` on all Packer templates.
 * Prefer MIT-licensed software where-ever possible.

## Modules

 * `app-cluster/aws/ecs-ami`
 * `app-cluster/aws/ecs-cluster`
 * `app-cluster/aws/ecs-deploy`
 * `app-cluster/aws/ecs-roles`
 * `app-cluster/aws/ecs-service`
 * `cache/aws/redis`
 * `cache/aws/memcached`
 * `ci/aws/install-jenkins`
 * `ci/aws/jenkins-ami`
 * `ci/aws/jenkins-server`
 * `ci/helpers/install-php`
 * `database/aws/aurora`
 * `load-balancer/aws/alb`
 * `load-balancer/aws/alb-target-group`
 * `monitoring/aws/logs`
 * `network/aws/bastion`
 * `network/aws/vpc`
 * `security/auto-update`
 * `security/fail2ban`
 * `storage/aws/efs`

## Getting Started

The root folder of this repository contains an oppinionated stack for launching MageCloudKit.

The `examples` folder contains real-world, production examples of how to use MageCloudKit.
