# ECS Deploy

This module allows you to deploy a new Docker image to an ECS Service running on
an ECS Cluster. It is based on the blue/green deployment script available here:
[https://github.com/silinternational/ecs-deploy](https://github.com/silinternational/ecs-deploy).

## Features

 * Rolling deployments via an ECS service update.
 * Re-use the previous task definition in the ECS service including environment variables.
 * Exit codes depending on the health of the deployment.

## Usage

Sample module usage:

```bash
$ ./ecs-deploy.sh -c production-app -n app-service -to 300 -i ignore -t 360
```

The `-to` parameter specifies the desired Docker image tag or Build ID from an Amazon ECR registry. The
`-t` parameter specifies how long in seconds, the script should wait for the deployment to complete.

You can run the script without any arguments to see further usage instructions.

```bash
$ ./ecs-deploy.sh
```
