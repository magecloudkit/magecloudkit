# ECS Service Module

Deploy one or more Docker containers as a long-running ECS service. This module includes support for automated, zero-downtime deployment, auto-restart of crashed containers and integration with an Application Load Balancer (ALB).

The service module creates an ecs service and task definition

A task definition is required to run Docker containers in Amazon ECS. Some of the parameters you can specify in a task definition include:

The Docker images to use with the containers in your task

How much CPU and memory to use with each container

The launch type to use, which determines the infrastructure on which your tasks are hosted

Whether containers are linked together in a task

The Docker networking mode to use for the containers in your task

(Optional) The ports from the container to map to the host container instance

Whether the task should continue to run if the container finishes or fails

The command the container should run when it is started

(Optional) The environment variables that should be passed to the container when it starts

Any data volumes that should be used with the containers in the task

(Optional) The IAM role that your tasks should use for permissions

## Usage

```
module "aws_ecs_web_service" {
  source = "./modules/app-cluster/aws/ecs-service"

  service_name = "web-service"
  vpc_id       = "${module.vpc.vpc_id}"
  subnet_ids   = "${module.vpc.private_subnets}"
  cluster      = "${module.ecs_cluster.cluster_name}"
  environment  = "production"

  task_definition = "${aws_ecs_task_definition.web_service.family}:${max("${aws_ecs_task_definition.web_service.revision}", "${data.aws_ecs_task_definition.web_service.revision}")}"
  desired_count   = 2
}

```
