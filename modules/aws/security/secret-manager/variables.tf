variable "enable" {
  default     = "true"
  description = "toggle on/off flag"
}

variable "name" {
  default     = "example"
  description = "AWS Secret Manager name"
}

variable "description" {
  default = "AWS Secret Manager"
}

variable "secret_data_values" {
  default = {
    key1 = "value1"
    key2 = "value2"
  }

  type = map(string)
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "A mapping of tags to assign to all resources."
}
