variable "enable" {
  default = "true"
}

variable "role_name" {
  default = "default_role_name"
}

variable "trusted_role_services" {
  description = "AWS Services that can assume these roles"
  type        = list(string)
  default     = ["ec2.amazonaws.com"]
}

variable "custom_role_policy_arns" {
  description = "List of ARNs of IAM policies to attach to IAM role"
  type        = list(string)
  default     = []
}

variable "policy" {
  description = "The path of the policy in IAM (tpl file)"
  type        = string
  default     = ""
}

variable "policy_enabled" {
  type        = bool
  default     = false
  description = "Whether to Attach Iam policy with role."
}

variable "policy_arn" {
  type        = string
  default     = ""
  description = "The ARN of the policy you want to apply."
}

variable "iam_role_description" {
  default = ""
}
variable "policy_description" {
  default = ""
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Map containing tags that will be added to the parameters"
}

variable "iam_instance_profile_name" {
  default = ""
}

variable "attached_role_name" {
  default = ""
}