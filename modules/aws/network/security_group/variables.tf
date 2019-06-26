variable security_group_name {}
variable vpc_id {}
variable environment {}
variable description {}
variable ingress_cidr_blocks {}
variable egress_cidr_blocks {}
variable create {
  description = "Whether to create security group and all rules"
  type        = bool
  default     = true
}