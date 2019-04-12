variable "aws_profile" {
  default = "default"
}

variable "vpc_name" {
  default = "Demoterraform"
}

variable "vpc_cidr_block" {}

variable "private_subnet" {
  type = "map"
}

variable "public_subnet" {
  type = "map"
}
