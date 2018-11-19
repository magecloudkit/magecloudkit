# Environments

An environment is a set of components used to create an infrastructure for a common purpose.
We recommend creating individual, isolated environments for the purposes of staging and production.
This will allow you to properly test changes before applying them to production by reducing the blast
radius.

## Global Environment

We recommend creating a global environment for storing resources that should be shared between
different environments. For example resources related to deployment and management purposes such
as Jenkins, IAM roles and policies and Amazon ECR repositories.

## Creating a new Environment

To create a new environment, simply run:

    $ terraform workspace new staging

Where `staging` is the name of your new environment.

Next run the Terraform `plan` command:

    $ terraform plan

And finally use the `apply` command to create a new environment:

    $ terraform apply

This step will take approximately 20-30 minutes. If the command fails creating AWS resources due to a
timeout or error then it is safe to run again.

**Note:** Terraform refers to the notion of environments as 'workspaces'.

## Destroying an environment

First switch to the desired environment. You can see a list of all environments using the Terraform
`workspace list` command:

    $ terraform workspace list

Select the environment you want, then destroy it using the `destroy` command:

    $ terraform workspace select staging
    $ terraform destroy

 
**Note:** you must type 'yes' to proceed. Be sure not to use this command unless you are
absolutely sure what you are doing.

Destroying an environment takes approximately 10 minutes, depending on the resources you have deployed.
