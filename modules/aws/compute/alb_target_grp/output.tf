output "alb_target_group_id_out" {
  value = "${aws_lb_target_group.target_group[0].id}"
}

output "alb_target_group_arn_out" {
  value = "${aws_lb_target_group.target_group[0].arn}"
}
