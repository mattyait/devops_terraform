variable "parameter_read" {
  type        = list(string)
  description = "List of parameters to read from SSM. These must already exist otherwise an error is returned. Can be used with `parameter_write` as long as the parameters are different."
  default     = []
}

variable "parameter_write" {
  type        = list(map(string))
  description = "List of maps with the parameter values to write to SSM Parameter Store"
  default     = []
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Map containing tags that will be added to the parameters"
}

variable "kms_arn" {
  type        = string
  default     = ""
  description = "The ARN of a KMS key used to encrypt and decrypt SecretString values"
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Set to `false` to prevent the module from creating and accessing any resources"
}

variable "split_delimiter" {
  type        = string
  default     = "~^~"
  description = "A delimiter for splitting and joining lists together for normalising the output"
}

variable "ignore_value_changes" {
  type = bool
  default = false
  description = "Ignore the Value change for SSM based on lifecycle ignore_change terraform"
}