output "ecs_default_task_iam_role_arn" {
  value = "${aws_iam_role.ecs_default_task.arn}"
}
