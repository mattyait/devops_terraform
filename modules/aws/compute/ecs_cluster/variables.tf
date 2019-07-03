variable "ecs_cluster_name" {
  description = "The ECS cluster name this will launching instances for."
  type        = "string"
}

variable "environment" {
  description = "Environment tag."
  type        = "string"
}

variable "image_id" {
  description = "Amazon ECS-Optimized AMI."
  type        = "string"
}

variable "instance_type" {
  description = "The instance type to use."
  type        = "string"
  default     = "t2.micro"
}

variable "vpc_id" {
  description = "The id of the VPC to launch resources in."
}

variable "subnet_ids" {
  description = "A list of subnet IDs to launch resources in."
  type        = "list"
}

variable "security_group_ids" {
  description = "A list of security group need to attach to ec2 as a part of ecs."
  type        = "list"
}

variable "desired_capacity" {
  description = "Desired instance count."
  type        = "string"
  default     = 2
}

variable "max_size" {
  description = "Maxmimum instance count."
  type        = "string"
  default     = 2
}

variable "min_size" {
  description = "Minimum instance count."
  type        = "string"
  default     = 2
}

variable "use_AmazonEC2ContainerServiceforEC2Role_policy" {
  description = "Attaches the AWS managed AmazonEC2ContainerServiceforEC2Role policy to the ECS instance role."
  type        = "string"
  default     = true
}

variable "key_name" {
  description = "KeyName use to connect to ec2 as a part of launch configuration"
  type  = "string"
  default = ""
}

variable "root_volume_size" {
  description = "Volume size of root block"
  type = "string"
  default = "10"
}

variable "ebs_volume_size" {
  description = "EBS volume size"
  type  = "string"
  default = "10"
}