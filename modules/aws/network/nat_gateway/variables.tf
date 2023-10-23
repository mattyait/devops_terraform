variable "subnet_id" {}
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(any)
  default     = {}
}