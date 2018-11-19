# Getting Started

## Requirements

 * [Terraform](https://www.terraform.io) v0.11.10
 * [Packer](https://www.packer.io) v1.3.2
 * `awscli`

As MageCloudKit requires Amazon EFS, only the following AWS regions are supported:

 * us-east-1
 * us-east-2
 * us-west-1
 * us-west-2
 * eu-central-1
 * eu-west-1
 * ap-northeast-1
 * ap-northeast-2
 * ap-southeast-1
 * ap-southeast-2

## Recommended Configurations

3000+ visitors per day
1000,000 orders per day

## Migrating to MageCloudKit

### PHP Extensions

MageCloudKit has the following PHP extensions enabled by default:

 * foo
 * TODO

If you use custom PHP extensions then you must use a custom `PHP.ini` file.

### PHP-FPM Configuration

[Determining the correct number of child processes for PHP-FPM on Nginx](https://www.kinamo.be/en/support/faq/determining-the-correct-number-of-child-processes-for-php-fpm-on-nginx)

### Timezones

MageCloudKit runs all servers using UTC and you should too! However this may affect your cron schedule and any 3rd party
scripts you use.

### Email Delivery

Configure SMTP. We recommend this plugin for Magento 1.9.

### Logs

As MageCloudKit runs applications using Docker, we recommend patching Magento to write to streams instead of files.

###  Preparing to Go Live

## Bootstrapping a new Environment

## Post Deployment Optimization

* PHP-FPM workers
* Cloudflare settings and features.
