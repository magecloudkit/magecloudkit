resource "aws_ecs_task_definition" "magento2_setup" {
  family = "${terraform.workspace}-magento2-setup"

  container_definitions = <<EOF
  [
    {
      "name": "magento2-setup",
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
          "awslogs-stream-prefix": "setup"
        }
      },
      "cpu": 0,
      "memoryReservation": 512,
      "command": [
        "rm",
        "/var/www/html/app/etc/env.php",
        "&&",
        "php",
        "/var/www/html/bin/magento",
        "setup:install",
        "--db-host=${aws_route53_record.db.fqdn}",
        "--db-name=${var.env_mysql_database}",
        "--db-user=${var.env_mysql_user}",
        "--db-password=${lookup(var.rds_password, terraform.workspace)}",
        "--base-url=http://${aws_alb.app.dns_name}/",
        "--admin-firstname=Mage",
        "--admin-lastname=CloudKit",
        "--admin-email=rob@magecloudkit.com",
        "--admin-user=magecloudkit",
        "--admin-password=M@gecl0udk1t",
        "--language=en_US",
        "--currency=USD",
        "--timezone=America/New_York",
        "--use-rewrites=1"
      ]
    }
  ]
EOF

  volume = {
    name      = "media"
    host_path = "/mnt/media"
  }
}
