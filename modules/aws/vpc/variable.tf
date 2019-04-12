variable "aws_profile" {
  default = "default"
}

variable "vpc_name" {
  default = "Demoterraform"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_cidr_block" {}

variable "private_subnet" {}

variable "public_subnet" {}

variable "availability_zone" {
  type = "map"
  default = {
  "us-east-1" = "us-east-1a,us-east-1b,us-east-1c,us-east-1e"
  "us-west-1" = "us-west-1a,us-west-1b"
  }
}
