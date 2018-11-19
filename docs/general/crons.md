# Crons

Magento requires cron jobs to run its indexer and cron commands. Additionally 3rd party extensions may require dedicated
cron jobs. MageCloudKit makes it easy to run cron jobs using its included modules.

## CloudWatch Scheduled Jobs

By default MageCloudKit runs crons using [CloudWatch Events][1]. To achieve this we create a dedicated ECS task
definition for cron jobs and then trigger them using a CloudWatch event target. The cron jobs then run on the App Cluster
at a specified time interval. For more information please refer to our included examples.

## Run crons using our Jenkins module

Customers with heavy workloads may wish to deploy Jenkins instead to run their cron jobs. MageCloudKit includes a number
of modules designed to run Jenkins on AWS. Jenkins is installed onto an Amazon AMI image and then runs within an EC2 Auto
Scaling Group. The data is stored on an EFS filesystem, meaning it can survive failures and restarts. The `examples`
directory contains an example of how to deploy a single instance Jenkins cluster.

[1]: https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/WhatIsCloudWatchEvents.html
