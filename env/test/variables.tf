variable environment {}
variable aws_profile  { default = "default" }
variable aws_region { default = "ap-southeast-2" }
variable vpc_name   { default = "" }
variable vpc_cidr_block { default = "" }
variable public_subnet_1a_cidr_block {}
variable public_subnet_1b_cidr_block {}
variable private_subnet_1a_cidr_block {}
variable private_subnet_1b_cidr_block {}

#==========EKS Variables========
variable instance_type {}
variable asg_min_size {}
variable asg_desired_capacity {}
variable asg_max_size {}
variable root_volume_size {}
variable root_volume_type {}
variable ami_id {}
variable key_name {}

