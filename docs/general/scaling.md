# Scaling

MageCloudKit supports automatic scaling using AWS Auto Scaling technologies. You can automatically configure your
store to scale up in periods of high traffic and scale down as necessary in order to reduce costs. Auto Scaling
is also used for redundancy purposes to replace failed containers and EC2 instances.

## ECS Services

By default, we follow an ordered placement strategy consisting of the following:

1. Spread tasks evenly across availability zones.
2. Spread tasks evenly across App Servers (ECS instances).
3. Binpack containers on their highest used resource (normally memory in Magento's case).

The reason for spreading tasks across availability zones follows the AWS best practice ensuring you have
high availability. This means if one zone was to fail entirely then your store would not go down. Binpacking
on the highest used resource allows great utilization by packing containers onto as few instances as possible.
This also allows you to save money by reducing the number of instances you run.

Further information about ECS task placement strategies can be found here: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-placement-strategies.html.

## Manually Scaling

If you ever need to manually scale before a high traffic event such as a marketing campaign then we recommend following
the following process:

1. Increase the number of instances in the EC2 Auto Scaling Group to the desired amount. **Note**: you must also adjust the maximum instance count if necessary.
2. Wait for the instances to boot and join the ECS cluster.
3. Increase the desired number of ECS tasks and ensure they are deployed to the App Cluster.

To scale down again simply revert the resources to their previous values. You can also scale manually using Terraform.
