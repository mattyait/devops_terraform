variable vpc_id     {}
variable cidr_block {}
variable gateway_id {}
variable tags {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}