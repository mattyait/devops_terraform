variable "create_role" {
  description = "Whether to create a role"
  type        = bool
  default     = true
}

variable "role_name" {
  description = "Role Name"
  default     = "default_role_name"
  type        = string
}

variable "trusted_role_services" {
  description = "AWS Services that can assume these roles"
  type        = list(string)
  default     = ["*"]
}

variable "principals_type" {
  description = "Type of Principals in the role"
  type        = string
  default     = "AWS"
}

variable "custom_role_policy_arns" {
  description = "List of ARNs of IAM policies to attach to IAM role"
  type        = list(string)
  default     = []
}

variable "policy" {
  description = "Rendered IAM policy from (tpl file)"
  type        = string
  default     = ""
}

variable "iam_role_description" {
  description = "IAM Role Description"
  type        = string
  default     = "Role for EKS ALB Controller"
}

variable "policy_description" {
  description = "IAM Policy Description"
  type        = string
  default     = "Policy for EKS ALB Controller"
}

variable "tags" {
  description = "Tags for the resources"
  type        = map(any)
  default     = {}
}

variable "allow_self_assume_role" {
  description = "Determines whether to allow the role to be [assume itself](https://aws.amazon.com/blogs/security/announcing-an-update-to-iam-role-trust-policy-behavior/)"
  type        = bool
  default     = false
}

variable "oidc_providers" {
  description = "Map of OIDC providers where each provider map should contain the `provider`, `provider_arn`, and `namespace_service_accounts`"
  type        = any
  default     = {}
}

variable "assume_role_condition_test" {
  description = "Name of the [IAM condition operator](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_condition_operators.html) to evaluate when assuming the role"
  type        = string
  default     = "StringEquals"
}

variable "max_session_duration" {
  description = "Maximum CLI/API session duration in seconds between 3600 and 43200"
  type        = number
  default     = null
}

variable "aws_region" {
  description = "AWS Region for Helm release"
  type        = string
  default     = "ap-southeast-2"
}

variable "vpc_id" {
  description = "AWS VPC ID"
  type        = string
}

variable "eks_cluster_name" {
  description = "EKS Cluster Name"
  type        = string
}

variable "aws_load_balancer_controller_version" {
  description = "AWS load balancer controller image version on ECR repo"
  type        = string
  default     = "v2.6.0"
}
