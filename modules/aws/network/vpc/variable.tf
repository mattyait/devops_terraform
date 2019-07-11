variable name {
  description = "VPC Name"
  default     = "demo"
}
variable tags {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
variable vpc_cidr_block {}
