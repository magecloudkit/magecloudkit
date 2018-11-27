# IAM Role for the lambda function
resource "aws_iam_role" "lambda_ecs_drain_role" {
  name = "${var.name}-lambda-ecs-drain-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# IAM Role AmazonEC2ContainerServiceRole policy attachment
resource "aws_iam_role_policy_attachment" "amazon_ec2container_service_role" {
  role       = "${aws_iam_role.lambda_ecs_drain_role.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

# IAM Role policy for the handling of the lifecycle
resource "aws_iam_role_policy" "lambda_drain_policy" {
  name = "${var.name}-lambda-drain-policy"
  role = "${aws_iam_role.lambda_ecs_drain_role.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "autoscaling:CompleteLifecycleAction",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceAttribute",
        "ec2:DescribeInstanceStatus",
        "ec2:DescribeHosts",
        "ecs:ListContainerInstances",
        "ecs:SubmitContainerStateChange",
        "ecs:SubmitTaskStateChange",
        "ecs:DescribeContainerInstances",
        "ecs:UpdateContainerInstancesState",
        "ecs:ListTasks",
        "ecs:DescribeTasks",
        "sns:Publish",
        "sns:ListSubscriptions"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

# Publishing the lambda function
resource "aws_lambda_function" "drain_lambda_function" {
  filename         = "${path.module}/lambda.zip"
  source_code_hash = "${base64sha256(file("${path.module}/lambda.zip"))}"
  function_name    = "${var.name}-lambda-ecs-drain"
  role             = "${aws_iam_role.lambda_ecs_drain_role.arn}"
  description      = "${var.name}-lambda-ecs-drain"
  handler          = "index.lambda_handler"
  runtime          = "python2.7"
  timeout          = "300"

  lifecycle {
    ignore_changes = ["filename", "last_modified"]
  }
}

module "lambda_function_logs" {
  source = "../../../monitoring/aws/logs"

  name              = "/aws/lambda/${var.name}-lambda-ecs-drain"
  retention_in_days = "${var.retention_in_days}"
}
