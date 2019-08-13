variable security_group_name {}
variable vpc_id {}
variable environment {}
variable description {}
variable ingress_cidr_blocks { default = "" }
variable ingress_with_source_security_group_id { default = "" }
variable egress_with_source_security_group_id { default = "" }
variable egress_cidr_blocks {}
variable create {
  description = "Whether to create security group and all rules"
  type        = bool
  default     = true
}
variable enable {
  description = "This flag is needed as toggle on/off condition until https://github.com/hashicorp/terraform/issues/953 resolve"
  default = "true"
}
