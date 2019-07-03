output "alb_loadbalancer_id_out" {
    value = "${join("", aws_lb.load-balancer.*.id)}"
}

output "alb_loadbalancer_noaccess_log_id_out" {
    value = "${join("", aws_lb.load-balancer-noaccess-logs.*.id)}"
}

output "alb_target_group_id_out" {
  value = "${module.alb_target_group.alb_target_group_id_out}"
}