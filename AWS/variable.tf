variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "private_subnet" {
  type = "map"
  default = {
    "subnetA" = "10.0.1.0/24"
    "subnetB" = "10.0.2.0/24"
  }
}

variable "public_subnet" {
  default = {
    "subnetA" = "10.0.3.0/24"
    "subnetB" = "10.0.4.0/24"
  }
}

variable "public_route_cidr" {
  default = "10.0.0.0/16"
}
