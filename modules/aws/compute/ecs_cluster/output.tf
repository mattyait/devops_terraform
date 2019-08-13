output "ecs_cluster_arn_out" {
  description = "The ARN of the ECS cluster."
  value       = "${aws_ecs_cluster.main[0].arn}"
}

output "ecs_cluster_name_out" {
  description = "The name of the ECS cluster."
  value       = "${aws_ecs_cluster.main[0].name}"
}

output "ecs_instance_role_out" {
  description = "The name of the ECS instance role."
  value       = "${aws_iam_role.ecs_instance_role[0].name}"
}
