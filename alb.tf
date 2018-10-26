# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY AN ALB LOAD BALANCER TO SERVE TRAFFIC TO THE CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

module "alb" {
  source = "./modules/load-balancer/aws/alb"

  name       = "${var.environment}-app-alb"
  vpc_id     = "${module.vpc.vpc_id}"
  subnet_ids = "${module.vpc.public_subnets}"

  security_groups = ["${aws_security_group.alb_web.id}"]

  create_log_bucket   = true
  log_bucket_name     = "${var.project_name}-alb-logs"
  log_location_prefix = "app-alb-logs"

  # Enable HTTPS on the load balancer. We are referencing the KiwiCo 'KiwiCoGoDaddy' certificate.
  https_listeners       = "${list(map("certificate_arn", "arn:aws:acm:us-west-1:054130723771:certificate/1a6b062a-4225-443a-a981-47a40aba62fb", "port", 443))}"
  https_listeners_count = "1"

  http_tcp_listeners       = "${list(map("port", "80", "protocol", "HTTP"))}"
  http_tcp_listeners_count = "1"
  target_groups            = "${list(map("name", "${var.project_name}-web", "backend_protocol", "HTTP", "backend_port", "80"), map("name", "${var.project_name}-checkout", "backend_protocol", "HTTP", "backend_port", "80"), map("name", "${var.project_name}-admin", "backend_protocol", "HTTP", "backend_port", "80"))}"
  target_groups_count      = "3"

  # Set custom tags
  tags = {
    Environment = "${var.environment}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE SECURITY GROUPS FOR THE ALB
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "alb_web" {
  description = "Security group for the ALB that allows web traffic from internet"
  vpc_id      = "${module.vpc.vpc_id}"

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
    Name        = "${var.environment}-sg-alb-web"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "alb_to_ecs" {
  type                     = "ingress"
  from_port                = 32768
  to_port                  = 61000
  protocol                 = "TCP"
  source_security_group_id = "${aws_security_group.alb_web.id}"
  security_group_id        = "${module.app_cluster.security_group_id}"
}

resource "aws_security_group_rule" "alb_to_ecs_admin" {
  type                     = "ingress"
  from_port                = 32768
  to_port                  = 61000
  protocol                 = "TCP"
  source_security_group_id = "${aws_security_group.alb_web.id}"
  security_group_id        = "${module.admin_cluster.security_group_id}"
}

resource "aws_security_group_rule" "alb_to_ecs_checkout" {
  type                     = "ingress"
  from_port                = 32768
  to_port                  = 61000
  protocol                 = "TCP"
  source_security_group_id = "${aws_security_group.alb_web.id}"
  security_group_id        = "${module.checkout_cluster.security_group_id}"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE IAM ROLES AND ATTACH ECS POLICIES
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "ecs_lb_role" {
  name = "${var.environment}_ecs_lb_role"
  path = "/ecs/"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ecs.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_lb" {
  role       = "${aws_iam_role.ecs_lb_role.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

##### RULES
# IF
# Host is atlascrate.com
# THEN
# Redirect tohttps://www.kiwico.com:443/atlas/#{path}?#{query}
# Status code:HTTP_301
# IF
# Host is tadpolecrate.com
# THEN
# Redirect tohttps://www.kiwico.com:443/tadpole/#{path}?#{query}
# Status code:HTTP_301
# IF
# Host is *.tadpolecrate.com
# THEN
# Redirect tohttps://www.kiwico.com:443/tadpole/#{path}?#{query}
# Status code:HTTP_301
# IF
# Host is *.atlascrate.com
# THEN
# Redirect tohttps://www.kiwico.com:443/atlas/#{path}?#{query}
# Status code:HTTP_301
