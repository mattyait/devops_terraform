output "alb_loadbalancer_id_out" {
    value = "${aws_lb.load-balancer.id}"
}

output "alb_target_group_id_out" {
  value = "${module.alb_target_group.alb_target_group_id_out}"
}