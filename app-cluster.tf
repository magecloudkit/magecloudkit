# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY AN ECS CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

module "ecs_cluster" {
  source = "./modules/app-cluster/aws/ecs-cluster"

  cluster_name  = "${var.ecs_cluster_name}"
  ami_id        = "${var.ecs_ami}"
  instance_type = "c5.large"

  user_data = "${data.template_file.user_data_ecs.rendered}"

  vpc_id     = "${module.vpc.vpc_id}"
  subnet_ids = "${module.vpc.private_subnets}"

  # To make testing easier, we allow SSH requests from any IP address here. In a production deployment, we strongly
  # recommend you limit this to the IP address ranges of known, trusted servers.
  allowed_ssh_cidr_blocks = ["0.0.0.0/0"]

  # Allow inbound SSH access from the Bastion instance
  allowed_ssh_security_group_ids = ["${module.bastion.security_group_id}"]

  key_pair_name = "${var.key_pair_name}"

  # custom docker volume
  #ebs_block_device {
  #  device_name = "/dev/xvdcz"
  #  volume_type = "gp2"
  #  volume_size = "25"
  #}

  # An example of custom tags
  tags = [
    {
      key                 = "Environment"
      value               = "development"
      propagate_at_launch = true
    },
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# THE USER DATA SCRIPT THAT WILL RUN ON THE ECS INSTANCES WHEN THEY ARE BOOTING
#
# This script will configure the instances to join the specified ECS cluster.
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "user_data_ecs" {
  template = "${file("./modules/app-cluster/aws/ecs-cluster/user-data/user-data.sh")}"

  vars {
    environment = "${var.environment}"
    cluster     = "${var.ecs_cluster_name}"
    aws_region  = "${var.aws_region}"

    mysql_host     = "db.magecloudkit.internal"
    mysql_database = "magento"
    mysql_user     = "magento"
    mysql_password = "magento"

    #mysql_host     = "${aws_route53_record.db.fqdn}"
    #mysql_database = "${var.env_mysql_database}"
    #mysql_user     = "${var.env_mysql_user}"
    #mysql_password = "${lookup(var.rds_password, terraform.workspace)}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# WEB-SERVICE - ECS-SERVICE
#
# This module will create ecs-service for web-service
# ---------------------------------------------------------------------------------------------------------------------

# REPOSITORY URL FOR WEB SERVICE APP
data "aws_ecr_repository" "web_service_app" {
  name = "kiwico/web_service"
}

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

// Gets the current task definition from AWS, reflecting anything that's been deployed
// outside of Terraform (e.g: CI builds).
data "aws_ecs_task_definition" "web_service" {
  task_definition = "${aws_ecs_task_definition.web_service.family}"
  depends_on      = ["aws_ecs_task_definition.web_service"]
}

resource "aws_ecs_task_definition" "web_service" {
  family        = "production-web-service"
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
      "image": "${data.aws_ecr_repository.web_service_app.repository_url}",,
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
          "awslogs-group": "production-web-service",
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
    }
  ]
EOF
}

#
# This role lets ECS tasks access AWS. We're using it for managing secrets and S3 access.
#
resource "aws_iam_role" "app_ecs_task_role" {
  name = "${terraform.workspace}-app-ecs-task-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
