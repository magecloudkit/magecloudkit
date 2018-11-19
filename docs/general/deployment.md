# CI & Deployment

In general we recommend using a 3rd party continuous integration provider such as [CircleCI][1] for deployment. Using CircleCI,
your application code is packaged into Docker images and then deployed to the App Cluster following a rolling deployment
model. This ensures there is no downtime during the deployment process.

**Note:** This section refers to continuous integration and code deployment. If you are looking to modify infrastructure then
refer to the [Infrastructure](instructure.md) section.

## The Build Process

When a new branch or commit is pushed to GitHub a webhook will automatically trigger a new build on CircleCI. CircleCI is
responsible for building the Docker images and then pushing them to a registry hosted on Amazon ECR. As a DevOps best
practice - both the staging and production environments are design to run the same Docker images.

### Setting up a new project on CircleCI

You can add a new project using the CircleCI Web UI.

We recommend creating a dedicated IAM user and policy for CircleCI to restrict access.

Then you will need to ensure the following environment variables are set:

* `AWS_REGION=us-east-1`
* `AWS_ACCESS_KEY_ID=AKIA1234567890`
* `AWS_SECRET_ACCESS_KEY=foob@r`
* `AWS_ECR_URL=12345678901.dkr.ecr.us-east-1.amazonaws.com`

## The Deployment Process

### Deploying a new version

You can use the included script in the [`ecs-deploy`](../../modules/app-cluster/aws/ecs-deploy/README.md) module:

```bash
$ ./modules/app-cluster/aws/ecs-deploy/ecs-deploy.sh -c production-app -n web-service -to <BUILD_ID> -i ignore -t 360
```

**Note:** You should replace `<BUILD_ID>` with the desired CircleCI Build ID.

New deployments will automatically flush the Magento cache and Magento 2.2 deployments will additionally run the
`setup:upgrade` command.

Further information on Magento 2.2 deployment can be found in the [Magento documentation][2].

### Rolling Back

Simply run another deployment using the known `<BUILD_ID>` that works:

```bash
$ ./modules/app-cluster/aws/ecs-deploy/ecs-deploy.sh -c production-app -n web-service -to <BUILD_ID> -i ignore -t 360
```

Alternatively, you can open the AWS Console and set the ECS service to the former task definition.

### Verifying the current deployment

You can check the current deployment’s Git SHA hash by accessing the
`REVISION.txt` file:

```bash
$ curl https://www.example.com/REVISION.txt
```

[1]: https://circleci.com/
[2]: http://devdocs.magento.com/guides/v2.2/config-guide/deployment/
