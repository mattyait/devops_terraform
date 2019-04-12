variable "aws_profile" {
  default = "default"
}

variable "vpc_name" {
  default = "Demoterraform"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "private_subnet" {
  default = "10.0.1.0/24,10.0.2.0/24"
}

variable "public_subnet" {
  default = "10.0.3.0/24,10.0.4.0/24"
}

variable "availability_zone" {
  type = "map"
  default = {
  "us-east-1" = "us-east-1a,us-east-1b,us-east-1c,us-east-1e"
  "us-west-1" = "us-west-1a,us-west-1b"
  }
}
