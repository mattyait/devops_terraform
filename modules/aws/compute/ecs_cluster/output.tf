output "ecs_cluster_id_out" {
  value       = "${aws_ecs_cluster.ecs_cluster.id}"
}

output "ecs_cluster_arn_out" {
  value       = "${aws_ecs_cluster.ecs_cluster.arn}"
}
