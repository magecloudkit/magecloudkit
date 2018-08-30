# MageCloudKit PoC

This repository serves as placeholder for the next version of MageCloudKit.

## Design Goals

 * Remove the concept of environments. We'll leave this up to the customer to define which environments they want to use.
 * In reference to the point above, don't have any references to Terraform workspaces.
 * All logic should be encapsulated in modules where-ever possible.
 * A module may consist of Terraform, Packer, Bash, Python or Go code.
 * Be sure to run `terraform fmt` on all Terraform code and `packer validate` on all Packer templates.
 * Prefer MIT-licensed software where-ever possible.

## Modules

 * app-cluster
 * cache
 * database
 * deploy
 * load-balancer
 * monitoring
