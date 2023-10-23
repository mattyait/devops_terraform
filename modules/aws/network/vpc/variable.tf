variable "name" {
  description = "VPC Name"
  default     = "demo"
}
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(any)
  default     = {}
}
variable "vpc_cidr_block" {}
variable "enable" {
  default = "true"
}
