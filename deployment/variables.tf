#====Global Vairable for whole suite====
variable environment {}
variable aws_profile { default = "default" }
variable aws_region { default = "ap-southeast-2" }

#====terraform VPC variables====
variable vpc_name { default = "" }
variable vpc_cidr_block { default = "" }
variable public_subnet_1a_cidr_block {}
variable public_subnet_1b_cidr_block {}
variable private_subnet_1a_cidr_block {}
variable private_subnet_1b_cidr_block {}

#=========ECS Variables==========
variable ecs_cluster_name { default = "app-demo" }
variable ecs_security_group_name {}
variable ecs_alb_target_group_name {}
variable ecs_asg_desired_count { default = "1" }
variable ecs_asg_min_count { default = "1" }
variable ecs_asg_max_count { default = "2" }
variable ecs_ec2_desired_capacity { default = "1" }
variable ecs_ec2_min_size { default = "1" }
variable ecs_ec2_max_size { default = "2" }
variable ecs_scale_up_cooldown_seconds { default = "300" }
variable ecs_scale_down_cooldown_seconds { default = "300" }
variable ecs_ec2_ami {}
variable ecs_ec2_instance_type { default = "t2.micro" }
variable ecs_alb_security_group_name {}
variable ec2_root_volume_size {}
variable ec2_ebs_volume_size {}
variable ecs_name {}
variable target_container_name {}
variable container_image {}
variable container_port {}
variable host_port {}

#==========EKS Variables========
variable eks_cluster_name {}
variable instance_type {}
variable asg_min_size {}
variable asg_desired_capacity {}
variable asg_max_size {}
variable root_volume_size {}
variable root_volume_type {}
variable ami_id {}
variable key_name {}

#==========RDS Variables========
variable rds_name {}
variable db_engine {}
variable db_engine_version {}
variable db_instance_type {}
variable db_allocated_storage {}
variable db_username {}
variable db_password {}
