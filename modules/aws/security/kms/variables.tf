variable "account_id" {
  description = "The account ID where the key will be created"
  type        = string
}

variable "key_admin_arn" {
  description = "The arns of the IAM roles that receive key administration rights"
  type        = list(string)
}

variable "key_user_arn" {
  description = "The arns of the IAM roles that receive general key usage rights"
  type        = list(string)
}

variable "key_description" {
  type = string
}

variable "key_deletion_window_in_days" {
  type        = number
  description = "The key deletion window in days"
  default     = 30
}

variable "key_alias" {
  type        = string
  description = "The key alias in the format alias/alias_name"
  // validation {
  //   condition       = can(regex("^alias/", var.key_alias))
  //   error_message   = "The key_alias value must start with / be in the format \"alias/key_alias\"."
  // }
}

variable "tags" {
  description = "A map of tags to apply to deployed resources"
  type        = map
}