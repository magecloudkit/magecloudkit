# ---------------------------------------------------------------------------------------------------------------------
# CHECKOUT-SERVICE - ECS-SERVICE
#
# This module will create ecs-service for web-service
# ---------------------------------------------------------------------------------------------------------------------

module "aws_ecs_checkout_service" {
  source = "./modules/app-cluster/aws/ecs-service"

  service_name = "web-service"
  vpc_id       = "${module.vpc.vpc_id}"
  subnet_ids   = "${module.vpc.private_subnets}"
  cluster      = "${module.ecs_cluster.cluster_name}"
  environment  = "production"

  task_definition = "${aws_ecs_task_definition.checkout_service.family}:${max("${aws_ecs_task_definition.checkout_service.revision}", "${data.aws_ecs_task_definition.checkout_service.revision}")}"
  desired_count   = 2
}

// Gets the current task definition from AWS, reflecting anything that's been deployed
// outside of Terraform (e.g: CI builds).
data "aws_ecs_task_definition" "checkout_service" {
  task_definition = "${aws_ecs_task_definition.web_service.family}"
  depends_on      = ["aws_ecs_task_definition.checkout_service"]
}

resource "aws_ecs_task_definition" "checkout_service" {
  family        = "production-checkout-service"
  task_role_arn = "${aws_iam_role.app_ecs_task_role.arn}"

  container_definitions = <<EOF
  [
    {
      "dnsSearchDomains": [],
      "environment": [],
      "readonlyRootFilesystem": false,
      "name": "nginx",
      "links": [
        "web"
      ],
      "mountPoints": [],
      "image": "857346137638.dkr.ecr.us-west-1.amazonaws.com/brightfame/nginx",
      "privileged": false,
      "essential": true,
      "portMappings": [
        {
          "protocol": "tcp",
          "containerPort": 80,
          "hostPort": 80
        }
      ],
      "dnsServers": [],
      "dockerSecurityOptions": [],
      "entryPoint": [],
      "ulimits": [],
      "memoryReservation": 512,
      "command": [],
      "extraHosts": [],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "production-checkout-service",
          "awslogs-region": "eu-west-1",
          "awslogs-stream-prefix": "webapp/nginx"
        }
      },
      "cpu": 0,
      "volumesFrom": [
        {
          "readOnly": false,
          "sourceContainer": "web"
        }
      ],
      "dockerLabels": {}
    },
    {
      "dnsSearchDomains": [],
      "environment": [],
      "readonlyRootFilesystem": false,
      "name": "nginx",
      "links": [
        "web"
      ],
      "mountPoints": [],
      "image": "857346137638.dkr.ecr.us-west-1.amazonaws.com/brightfame/magento",
      "privileged": false,
      "essential": true,
      "portMappings": [],
      "dnsServers": [],
      "dockerSecurityOptions": [],
      "entryPoint": [],
      "ulimits": [],
      "memoryReservation": 512,
      "command": [],
      "extraHosts": [],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "production-checkout-service",
          "awslogs-region": "eu-west-1",
          "awslogs-stream-prefix": "webapp/magento"
        }
      },
      "cpu": 0,
      "volumesFrom": [
        {
          "readOnly": false,
          "sourceContainer": "web"
        }
      ],
      "dockerLabels": {}
    }
  ]
EOF
}
