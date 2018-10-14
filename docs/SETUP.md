# MageCloudKit Setup

This document outlines creating a new MageCloudKit environment.

This guide has been prepared for macOS, but can be easily adapted for Linux
systems. Windows users may wish to use the Ubuntu for Windows application
(https://www.microsoft.com/en-us/store/p/ubuntu/9nblggh4msv6).

## Prerequisite Software

You should have the following software tools installed locally:

 * Packer (at least v1.0.4)
 * Terraform (at least v0.10.3)
 * AWS CLI tools (at least v1.11.138)
 * [Docker for Mac](https://docs.docker.com/engine/installation/mac/)
 * [jq](https://stedolan.github.io/jq)
 * [awslogs](https://github.com/jorgebastida/awslogs)

If you are using macOS then you can use the Homebrew package manager to install all of them except Docker for Mac.

    $ make dev-bootstrap

## AWS Credentials

In order to create resources MageCloudKit will need an AWS IAM key pair with a privileged
policy attached. These credentials can be easily created using the AWS console.

 1. Open the AWS Console in your web browser.
 2. Create a new IAM Group called 'Admins'.
 3. Attach the AWS 'AdministratorAccess' policy to the group.
 4. Create a new IAM user and add it to the 'Admins' group.
 5. Click on the user then find the 'Security Credentials' tab.
 6. Use the 'Create access key' button to create new AWS access keys.

We recommend to create the IAM users in the form: first initial/last name.

e.g: `rmorgan` for Rob Morgan.

Next we need to configure our local environment:

    export AWS_DEFAULT_REGION=us-east-1
    export AWS_ACCESS_KEY_ID=xyz
    export AWS_SECRET_ACCESS_KEY=xyz

**Note:** As a best practice you should add these variables to your `.bashrc` or `.zshrc` file so they are
always available.

Next run `aws configure` to configure the AWS CLI tools.

Now test your configuration:

```
$ aws ec2 describe-instances
```

If the credentials are valid then you should see no errors.

## Optional: Adding your SSH keys

Public SSH keys can be added in the `ssh_keys` directory. These keys will be automatically provisioned
onto the servers. If you have an SSH public key then add it to this directory in the format: `keyname.pub`.

## Baking a new App AMI

Now we need to bake the App AMI using Packer. The App AMI is an Amazon Machine
Image used to launch application servers inside the MageCloudKit environment.

To bake the AMI, simply run:

    $ make bake-ami

Packer will run and bake the App AMI. This process will take roughly 10 minutes. When Packer finishes it will output an 'AMI ID'. Be sure to note this value down as we'll need it in a future step. The AMI ID takes the format: `ami-XXYYZZZZ`.

**Note:** You can also use the `get-ami` command to access the AMI ID in the future:

    $ make get-ami

## Edit the Terraform Configuration

Now we need to edit the Terraform configuration to customize it for the new environment.

 1. Open the `terraform/main.tf` and change the `project_name` variable. This name is used for global resources on AWS so it must be unique. Generally your domain name or company name is suitable. E.g: johnsontoys, nestle or applecom.
 2. Change the `ecs_ami` variable to the AMI ID you generated in the previous step.
 3. Rotate the `rds_password` values if you desire. We recommend using a 32 character alphanumeric string.

## Creating a Terraform State Bucket

MageCloudKit stores the Terraform state in a remote S3 bucket so it can be shared amongst teams. However this bucket
is not automatically provisioned by Terraform and must be created manually. It is a good idea to use the `project_name` value again here when creating the S3 Bucket:

     $ aws s3api create-bucket --bucket projectname-state --region us-east-1
     $ aws s3api put-bucket-versioning --bucket projectname-state --versioning-configuration Status=Enabled

**Note:** Regions outside of `us-east-1` require the appropriate `LocationConstraint` to be specified in order to create the bucket in the desired region:

     $ aws s3api create-bucket --bucket projectname-state --region us-west-1 --create-bucket-configuration LocationConstraint=us-west-1
     $ aws s3api put-bucket-versioning --bucket projectname-state --versioning-configuration Status=Enabled

Edit the `terraform/terraform.tf` file to add your state bucket name.

When you have finished we must run the `init` command to initalize the Terraform configuration:

    $ make init

Terraform will parse the configuration then download and install all of the required plugins for MageCloudKit.

## Creating a new MageCloudKit environment

If you haven't already done so we need to create a private key pair to be used for deploying new environments:

    $ make keygen

This will generate the required files under the `private` directory. It is recommended to share this key pair
amongst your team.

Now its time to create a new MageCloudKit environment.

Simply run:

    $ make create-env ENV=production

Next generate a Terraform plan:

    $ make plan

And finally run the Terraform apply step to create the AWS resources:

    $ make apply

This step will take approximately 20-30 minutes. If the command fails creating AWS resources due to a
timeout or error then it is safe to run again.

***Note:*** This command will eventually timeout as we have not yet deployed the Magento application.

## Building the Docker Images

First get the repository URL as we'll need it for the next step:

    $ make get-ecr

MageCloudKit uses Docker and ECS to run the applications on AWS. Ensure Docker is running then run the
`build` and `push` commands:

    $ make build BUILD_NUM=latest && make push BUILD_NUM=latest AWS_ECR_URL=111111111111.dkr.ecr.us-east-1.amazonaws.com

**Note:** Be sure to substitute your registry URL in the `AWS_ECR_URL` variable.

## Deploying the images

Simply re-run the `plan` and `apply` commands to deploy the recently pushed images:

    $ make plan
    $ make apply

Terraform should now complete successfully, however we still need to run the Magento installer.

## Running the Magento Setup Wizard

In order to create the database and initialize Magento we need to run the setup wizard using the ECS Run Task functionality.

    $ aws ecs run-task --cluster production-app --task-definition production-magento2-setup:1

The Magento installer will take approximately 5-10 mins to complete.
If desired you can watch the setup progress from the AWS CloudWatch Logs console or by using the `awslogs` tool:

    $ awslogs get production-app -w

## Visit Your Store

Congratulations! Your new MageCloudKit environment should now be available. Unless configured otherwise
the admin URL will be accessible at `http://<yourdomain>/admin_xuyq8u`.

The default admin credentials are:

* Username: `magecloudkit`
* Password: `M@gecl0udk1t`

**Note:** It is recommended to change them immediately.
