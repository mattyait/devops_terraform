variable "instance_type" {}

variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "us-east-1"
}

variable "aws_amis" {
  default = {
    "us-east-1" = "ami-5f709f34"
    "us-west-2" = "ami-7f675e4f"
  }
}

variable "availability_zones" {}

variable "security_groups" {}

variable "asg_max" {}

variable "asg_desired" {}

variable "launch_config_name" {}

variable "instance_type" {}

variable "asg_name" {}

variable "keyname" {}

variable "asg_min" {}

variable "health_check_grace_period" {}

variable "health_check_type" {}

variable "elb_name" {}
