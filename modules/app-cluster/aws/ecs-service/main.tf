# ---------------------------------------------------------------------------------------------------------------------
# DEFINE MINIMUM TERRAFORM VERSION
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 0.10.3"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE AWS ECS SERVICE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ecs_service" "service" {
  service_name = "${var.service_name}"
  cluster      = "${var.cluster}"

  // check the data provider so we don't deploy an old version of the container when re-running terraform
  desired_count                      = "${var.desired_count}"
  task_definition                    = "${var.task_definition}"
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  security_groups                    = ["${aws_security_group.alb_web.id}"]

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
    "aws_alb_listener.app_https",
  ]
}

resource "aws_iam_role" "app_ecs_service_role" {
  name = "prod-ecs-service-role"

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

/* Security group for the public facing load balancers */
resource "aws_security_group" "alb_web" {
  name        = "${var.environment}_alb_web"
  description = "Security group for web that allows web traffic from internet"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "sg-${var.environment}-alb-web"
    Environment = "${var.environment}"
  }
}

resource "aws_alb" "app" {
  name     = "${var.aws_alb_name}"
  internal = false
  subnets  = ["${var.subnet_ids}"]

  access_logs {
    bucket = "${var.aws_alb_access_logs_bucket}"
    prefix = "${var.aws_alb_name}"
  }

  tags {
    Name        = "${var.aws_alb_name}"
    Environment = "${var.environment}"
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

resource "aws_alb_listener" "app_https" {
  load_balancer_arn = "${aws_alb.app.id}"
  port              = "443"
  protocol          = "HTTPS"

  #certificate_arn   = "${var.certificate_arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.app.id}"
    type             = "forward"
  }
}

resource "aws_alb_target_group" "app" {
  name     = "${var.environment}-app"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  # Minimum connection draining time
  deregistration_delay = 60

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 8
    timeout             = 4
    path                = "/_status"
    interval            = 10
    matcher             = "200"      # http code
  }
}
