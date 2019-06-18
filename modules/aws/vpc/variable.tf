variable "aws_profile" {
  default = "default"
}

variable "vpc_name" {
  default = "Demoterraform"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "env" {
  default = "dev"
}

variable "vpc_cidr_block" {}

variable "private_subnet" {}

variable "public_subnet" {}

variable "availability_zone" {
  type = "map"

  default = {
    "us-east-1" = "us-east-1a, us-east-1b, us-east-1c, us-east-1e"
    "us-west-1" = "us-west-1a, us-west-1b"
    "us-west-2" = "us-west-2a, us-west-2b, us-west-2c"
    "eu-west-1" = "eu-west-1a, eu-west-1b, eu-west-1c"
    "ap-southeast-2" = "ap-southeast-2a, ap-southeast-2b, ap-southeast-2c"
  }
}