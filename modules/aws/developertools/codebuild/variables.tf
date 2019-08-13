variable "enable" {
  default     = "true"
  description = "toggle on/off flag"
}

variable "name" {
  type        = "string"
  default     = "codebuild"
  description = "The projects name."
}

variable "description" {
  default     = "Managed by Terraform"
  type        = "string"
  description = "The description of the all resources."
}

variable "service_role" {
  default     = ""
  description = "Arn of service role need to attest to codebuild project"
}

variable "environment_type" {
  default     = "LINUX_CONTAINER"
  type        = "string"
  description = "The type of build environment to use for related builds."
}

variable "compute_type" {
  default     = "BUILD_GENERAL1_SMALL"
  type        = "string"
  description = "Information about the compute resources the build project will use."
}

variable "image" {
  default     = "aws/codebuild/ubuntu-base:14.04"
  type        = "string"
  description = "The image identifier of the Docker image to use for this build project."
}

variable "privileged_mode" {
  default     = true
  type        = "string"
  description = "If set to true, enables running the Docker daemon inside a Docker container."
}

variable "buildspec" {
  default     = ""
  type        = "string"
  description = "The build spec declaration to use for this build project's related builds."
}

variable "cache_type" {
  default     = "NO_CACHE"
  type        = "string"
  description = "The type of storage that will be used for the AWS CodeBuild project cache."
}

variable "cache_location" {
  default     = ""
  type        = "string"
  description = "The location where the AWS CodeBuild project stores cached resources."
}

variable "build_timeout" {
  default     = 60
  type        = "string"
  description = "How long in minutes to wait until timing out any related build that does not get marked as completed."
}

variable "tags" {
  default     = {}
  type        = "map"
  description = "A mapping of tags to assign to all resources."
}

variable "source_provider" {
  default = ""
}

variable "repository_url" {
  default = ""
}

variable "environment_variables" {
  type = list(object(
    {
      name  = string
      value = string
  }))

  default = [
    {
      name  = "NO_ADDITIONAL_BUILD_VARS"
      value = "TRUE"
  }]

  description = "A list of maps, that contain both the key 'name' and the key 'value' to be used as additional environment variables for the build"
}
