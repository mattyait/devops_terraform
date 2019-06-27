output "alb_target_group_id_out" {
  value = "${aws_lb_target_group.target_group.id}"
}
output "alb_target_group_arn_out" {
  value = "${aws_lb_target_group.target_group.arn}"
}