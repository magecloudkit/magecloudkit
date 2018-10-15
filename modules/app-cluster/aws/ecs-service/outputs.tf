output "aws_ecs_service" {
  value = "${aws_ecs_service.service.name}"
}

output "ecs_task_iam_role_name" {
  value = "${aws_iam_role.ecs_task.name}"
}
