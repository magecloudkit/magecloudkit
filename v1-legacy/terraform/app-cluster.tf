resource "aws_ecs_cluster" "cluster_app" {
  name = "${terraform.workspace}-app"

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_ecs_task_definition" "magento2" {
  task_definition = "${aws_ecs_task_definition.magento2.family}"

  depends_on = [
    "aws_ecs_task_definition.magento2",
  ]
}

/* Initial task definition - will be updated later by the deploy script */
resource "aws_ecs_task_definition" "magento2" {
  family = "${terraform.workspace}-magento2"

  container_definitions = <<EOF
  [
    {
      "name": "magento2",
      "image": "${data.aws_ecr_repository.magento2.repository_url}",
      "mountPoints": [
        {
          "containerPath": "/var/www/html/pub/media",
          "sourceVolume": "media",
          "readOnly": null
        }
      ],
      "essential": true,
      "environment": [
        {
          "name": "ENVIRONMENT",
          "value": "${terraform.workspace}"
        },
        {
          "name": "MAGE_MODE",
          "value": "production"
        },
        {
          "name": "CACHE_PREFIX",
          "value": "1_"
        },
        {
          "name": "MYSQL_HOST",
          "value": "${aws_route53_record.db.fqdn}"
        },
        {
          "name": "MYSQL_DATABASE",
          "value": "${var.env_mysql_database}"
        },
        {
          "name": "MYSQL_USER",
          "value": "${var.env_mysql_user}"
        },
        {
          "name": "MYSQL_PASSWORD",
          "value": "${lookup(var.rds_password, terraform.workspace)}"
        },
        {
          "name": "REDIS_CACHE_HOST",
          "value": "${aws_route53_record.redis_cache.fqdn}"
        },
        {
          "name": "REDIS_SESSION_HOST",
          "value": "${aws_route53_record.redis_session.fqdn}"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${terraform.workspace}-app",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "magento2"
        }
      },
      "cpu": 0,
      "memoryReservation": 768
    },
    {
      "name": "nginx",
      "volumesFrom": [
        {
          "readOnly": true,
          "sourceContainer": "magento2"
        }
      ],
      "portMappings": [
        {
          "hostPort": 80,
          "containerPort": 80,
          "protocol": "tcp"
        }
      ],
      "essential": true,
      "environment": [],
      "links": [
        "magento2:phpfpm"
      ],
      "image": "${data.aws_ecr_repository.nginx.repository_url}",
      "command": [],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${terraform.workspace}-app",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "nginx"
        }
      },
      "cpu": 0,
      "memoryReservation": 512
    }
  ]
EOF

  volume = {
    name      = "media"
    host_path = "/mnt/media"
  }
}

resource "aws_ecs_service" "magento2" {
  name    = "${terraform.workspace}-app"
  cluster = "${aws_ecs_cluster.cluster_app.id}"

  // check the data provider so we don't deploy an old version of the container when re-running terraform
  task_definition                    = "${aws_ecs_task_definition.magento2.family}:${max("${aws_ecs_task_definition.magento2.revision}", "${data.aws_ecs_task_definition.magento2.revision}")}"
  desired_count                      = "${lookup(var.app_task_count, terraform.workspace)}"
  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 50

  // Required so that the agent can talk to the load balancer
  iam_role = "${aws_iam_role.app_ecs_service_role.arn}"

  load_balancer = {
    target_group_arn = "${aws_alb_target_group.app.arn}"

    // This value come from the container definitions
    container_name = "nginx"
    container_port = "80"
  }

  depends_on = [
    "aws_alb_listener.app_http",
  ]

  /*
  depends_on = [
    "aws_alb_listener.app_http",
    "aws_alb_listener.app_https"
  ]
  */
}

resource "aws_appautoscaling_target" "service_appalb_asg_target" {
  resource_id        = "service/${aws_ecs_cluster.cluster_app.name}/${aws_ecs_service.magento2.name}"
  min_capacity       = 2
  max_capacity       = 6
  role_arn           = "${aws_iam_role.ecs_autoscale_role.arn}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_s3_bucket" "logs" {
  bucket        = "${var.project_name}-${terraform.workspace}-logs"
  acl           = "private"
  force_destroy = true

  policy = <<EOF
{
  "Id": "${var.project_name}-${terraform.workspace}-logs-policy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1484671540333",
      "Action": "s3:PutObject",
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.project_name}-${terraform.workspace}-logs/*",
      "Principal": {
        "AWS": "arn:aws:iam::${lookup(var.default_log_account_ids, var.aws_region)}:root"
      }
    }
  ]
}
EOF
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "${terraform.workspace}-app"
  retention_in_days = "30"

  tags {
    Environment = "${terraform.workspace}"
  }
}

resource "aws_alb" "app" {
  name            = "${terraform.workspace}-app-alb"
  internal        = false
  security_groups = ["${aws_security_group.alb_web.id}"]
  subnets         = ["${aws_subnet.public_az1.id}", "${aws_subnet.public_az2.id}", "${aws_subnet.public_az3.id}"]

  access_logs {
    bucket = "${aws_s3_bucket.logs.id}"
    prefix = "${terraform.workspace}-app-alb"
  }

  tags {
    Name        = "${terraform.workspace}-app-alb"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_alb_listener" "app_http" {
  load_balancer_arn = "${aws_alb.app.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.app.id}"
    type             = "forward"
  }
}

/*
resource "aws_alb_listener" "app_https" {
  load_balancer_arn = "${aws_alb.app.id}"
  port = "443"
  protocol = "HTTPS"
  certificate_arn = "${aws_iam_server_certificate.cloudflare.arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.app.id}"
    type = "forward"
  }
}
*/

resource "aws_alb_target_group" "app" {
  name     = "${terraform.workspace}-app"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.default.id}"

  # Minimum connection draining time
  deregistration_delay = 60

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 8
    timeout             = 4
    path                = "/health_check.php"
    interval            = 10
  }
}

resource "aws_autoscaling_group" "asg_app" {
  lifecycle {
    create_before_destroy = true
  }

  # spread the app instances across the availability zones
  availability_zones = ["${split(",", var.availability_zones)}"]

  # interpolate the LC into the ASG name so it always forces an update
  # see: https://github.com/robmorgan/terraform-rolling-deploys
  name = "${terraform.workspace}-asg-app - ${aws_launch_configuration.lc_app.name}"

  max_size                  = 5
  min_size                  = 2
  wait_for_elb_capacity     = 2
  desired_capacity          = "${lookup(var.app_server_count, terraform.workspace)}"
  termination_policies      = ["OldestInstance"]
  health_check_grace_period = 300
  health_check_type         = "EC2"
  launch_configuration      = "${aws_launch_configuration.lc_app.id}"
  vpc_zone_identifier       = ["${aws_subnet.private_az1.id}", "${aws_subnet.private_az2.id}", "${aws_subnet.private_az3.id}"]
  target_group_arns         = ["${aws_alb_target_group.app.arn}"]

  tag {
    key                 = "Name"
    value               = "${terraform.workspace}-app0${count.index+1}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "${terraform.workspace}"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "lc_app" {
  name_prefix = "${format("%s-", "${terraform.workspace}-app")}"

  image_id             = "${var.ecs_ami}"
  instance_type        = "c4.large"
  ebs_optimized        = "true"
  iam_instance_profile = "${aws_iam_instance_profile.ecs_app_instance_profile.id}"

  # Our Security group to allow HTTP and SSH access
  security_groups = ["${aws_security_group.default.id}", "${aws_security_group.app.id}"]

  user_data = "${data.template_file.template_app_ecs_user_data.rendered}"

  # root
  root_block_device {
    volume_type = "gp2"
    volume_size = "25"
  }

  # docker
  ebs_block_device {
    device_name = "/dev/xvdcz"
    volume_type = "gp2"
    volume_size = "25"
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "template_app_ecs_user_data" {
  template = "${file("user_data/app.sh")}"

  vars {
    ENVIRONMENT    = "${terraform.workspace}"
    MYSQL_HOST     = "${aws_route53_record.db.fqdn}"
    MYSQL_DATABASE = "${var.env_mysql_database}"
    MYSQL_USER     = "${var.env_mysql_user}"
    MYSQL_PASSWORD = "${lookup(var.rds_password, terraform.workspace)}"
    CLUSTER        = "${terraform.workspace}-app"
  }
}

/* Security group for the app instances */
resource "aws_security_group" "app" {
  name        = "sg_${terraform.workspace}_app"
  description = "Security group for app instances that allow web traffic inside the VPC"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  /* allow SSH access from the bastion instance */
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.bastion.id}"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "sg-${terraform.workspace}-app"
    Environment = "${terraform.workspace}"
  }
}

# This role and its attached policies lets the EC2 instances in the cluster
# talk to ECS, ECR and ELB
#
resource "aws_iam_role" "ecs_role" {
  name = "${terraform.workspace}-ecs-role"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "ecs.amazonaws.com",
          "ec2.amazonaws.com"
        ]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

# https://console.aws.amazon.com/iam/home?region=eu-west-1#policies/arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole
resource "aws_iam_role_policy_attachment" "ecs_service_instance_role_policy_attachment" {
  role       = "${aws_iam_role.ecs_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

# https://console.aws.amazon.com/iam/home?region=eu-west-1#policies/arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role
resource "aws_iam_role_policy_attachment" "ecs_instance_instance_role_policy_attachment" {
  role       = "${aws_iam_role.ecs_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# This profile lets us attach the role to an instance or a Launch Configuration
resource "aws_iam_instance_profile" "ecs_app_instance_profile" {
  name = "${terraform.workspace}-ecs-app-instance-profile"
  path = "/"
  role = "${aws_iam_role.ecs_role.id}"
}

#
# This role lets the ECS Service talk to the load balancer.
#
resource "aws_iam_role" "app_ecs_service_role" {
  name = "${terraform.workspace}-ecs-service-role"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "ecs.amazonaws.com"
        ]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

# https://console.aws.amazon.com/iam/home?region=eu-west-1#policies/arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole
resource "aws_iam_role_policy_attachment" "ecs_service_role_policy_attachment" {
  role       = "${aws_iam_role.app_ecs_service_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

#
# This role lets the ECS Service do application auto-scaling. (not the same as
# EC2 ASG)
# It is assigned to the appautoscaling_target
#
resource "aws_iam_role" "ecs_autoscale_role" {
  name = "${terraform.workspace}-ecs-autoscale-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "application-autoscaling.amazonaws.com"
        ]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_autoscale_role_policy_attachment" {
  role       = "${aws_iam_role.ecs_autoscale_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
}

#
# This role lets ECS tasks access AWS. We're using it for managing secrets in
# S3. The policy can be found in secrets.tf
#
resource "aws_iam_role" "app_ecs_task_role" {
  name = "${terraform.workspace}-app-ecs-task-role"
  path = "/"

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
