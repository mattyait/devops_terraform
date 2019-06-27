variable environment {}
variable type {}
variable lb_name { default = "demo" }
variable is_internal_lb { 
    type    = "string"
    default = false 
}
variable load_balancer_type {
  default   = "application"
}

variable security_groups {
    type = "list"
    default = []
}
variable subnets {
    type = "list"
    default = []
}
variable enable_cross_zone_load_balancing {
    type    = "string"
    default = false 
}
variable deletion_protection {
    type    = "string"
    default = false
}
variable aws_access_logs_bucket {
    type = "string"
    default = ""
}
variable sthree_logs_prefix {
    type = "string"
    default = ""
}
variable alb_target_group_name {}
variable vpc_id{}
variable target_group_port { default = "80" }
variable target_group_protocol { default = "HTTP" }