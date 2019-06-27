variable ecs_iam_role_name {}
variable environment {}
variable task_definition_name {}
variable ecs_use_fargate { default = false }
variable fargate_task_cpu {
  description = "Number of cpu units used in initial task definition. Default is minimum."
  default     = 256
  type        = "string"
}
variable fargate_task_memory {
  description = "Amount (in MiB) of memory used in initial task definition. Default is minimum."
  default     = 512
  type        = "string"
}
variable container_definitions {
  description = "Container definitions provided as valid JSON document. Default uses nginx:stable."
  default     = ""
  type        = "string"
}
variable trusted_role_arns {
  description = "ARNs of AWS entities who can assume these roles"
  type        = list(string)
  default     = []
}
variable default_container_definitions { default = "" }