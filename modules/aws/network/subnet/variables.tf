variable vpc_id                  {}
variable cidr_block              {}
variable availability_zone       {}
variable tags {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
variable name {
  description = "Subnet Name"
  default     = ""
}