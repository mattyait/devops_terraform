variable vpc_id { }
variable tags {
  description = "A map of tags to add to all resources"
  type        = map
  default     = {}
}