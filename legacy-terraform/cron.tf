resource "aws_cloudwatch_event_rule" "cron_schedule" {
  name                = "${terraform.workspace}-cron-schedule"
  description         = "magento cron schedule"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "magento_cron" {
  arn      = "${aws_ecs_cluster.cluster_app.id}"
  rule     = "${aws_cloudwatch_event_rule.cron_schedule.id}"
  role_arn = "${aws_iam_role.task_role.arn}"

  ecs_target {
    task_count          = 1
    task_definition_arn = "${aws_ecs_task_definition.magento2_cron.arn}"
  }
}

resource "aws_iam_role" "task_role" {
  name = "${terraform.workspace}-task-role"

  assume_role_policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [{
		"Action": "sts:AssumeRole",
		"Principal": {
			"Service": "events.amazonaws.com"
		},
		"Effect": "Allow",
		"Sid": ""
	}]
}
EOF
}

resource "aws_iam_role_policy" "run_task_policy" {
  name = "${terraform.workspace}-run-task-policy"
  role = "${aws_iam_role.task_role.id}"

  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [{
		"Effect": "Allow",
		"Action": [
			"ecs:RunTask"
		],
		"Resource": [
			"*"
		]
	}]
}
EOF
}

resource "aws_ecs_task_definition" "magento2_cron" {
  family = "${terraform.workspace}-magento2-cron"

  container_definitions = <<EOF
  [
    {
      "name": "magento2-cron",
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
          "awslogs-stream-prefix": "cron"
        }
      },
      "cpu": 0,
      "memoryReservation": 512,
      "command": [
        "php",
        "/var/www/html/bin/magento",
        "cron:run"
      ]
    },
    {
      "name": "magento2-indexer",
      "image": "${data.aws_ecr_repository.magento2.repository_url}",
      "mountPoints": [
        {
          "containerPath": "/var/www/html/pub/media",
          "sourceVolume": "media",
          "readOnly": null
        }
      ],
      "essential": false,
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
          "awslogs-stream-prefix": "indexer"
        }
      },
      "cpu": 0,
      "memoryReservation": 512,
      "command": [
        "php",
        "/var/www/html/bin/magento",
        "indexer:reindex"
      ]
    }
  ]
EOF

  volume = {
    name      = "media"
    host_path = "/mnt/media"
  }
}
