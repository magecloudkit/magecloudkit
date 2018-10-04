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

 * `app-cluster`
 * `cache/redis`
 * `database`
 * `deploy`
 * `load-balancer`
 * `monitoring`
 * `network`
 * `security`

## Problems with MageCloudKit v1

MageCloudKit v1 was essentially an MVP designed to validate the need for the product with real customers. It's served its purpose and now we are looking to develop the next version.

You can find the source code in the `v1-legacy` directory.

Historically, v1 suffers from:

 * Lack of Terraform modules.
 * Hard-coded `${terraform.workspace}` references.
 * Hard-coded view of how the 'world' should appear.

## Getting Started

The root folder of this repository contains an oppinionated stack for launching MageCloudKit.
