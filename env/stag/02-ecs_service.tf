#======= Creating ECS Cluster=========
module "app_ecs_cluster" {
  source            = "../../modules/aws/compute/ecs_cluster"    
  ecs_cluster_name  = "${var.ecs_cluster_name}"
  vpc_id              = "${module.vpc.vpc_id_out}"
  environment       = "${var.environment}"
  image_id          = "${var.ecs_ec2_ami}"
  instance_type     = "${var.ecs_ec2_instance_type}"
  subnet_ids       = ["${module.private_subnet_1a.subnet_id_out},${module.private_subnet_1b.subnet_id_out}"]
  desired_capacity = "${var.ecs_ec2_desired_capacity}"
  max_size         = "${var.ecs_ec2_max_size}"
  min_size         = "${var.ecs_ec2_min_size}"
  key_name         =  "${var.key_name}"
  root_volume_size  = "50"
  ebs_volume_size   = "50"
}


#======= Creating Security Group needed for ECS Service=========
module "ecs_security_group" {
  source              = "../../modules/aws/network/security_group"
  security_group_name = "${var.ecs_security_group_name}"
  vpc_id              = "${module.vpc.vpc_id_out}"
  environment         = "${var.environment}"
  description         = "ecs_cluster_sg"
  ingress_cidr_blocks = [
    {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        description = "ssh port open"
        cidr_blocks = ["10.20.0.0/19"]
    },
    {
        from_port   = 32768
        to_port     = 61000
        protocol    = "tcp"
        description = "Application port"
        cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  
  egress_cidr_blocks    =  [
    {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        description = "Allow outgoing traffic"
        cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

#===== This module will create target group as well as load balancer and attach=====
module "ecs_alb_loadbalancer" {
  source                            = "../../modules/aws/compute/alb_loadbalancer"
  lb_name                           = "ecs-alb"
  is_internal_lb                    = "false"
  load_balancer_type                = "application"
  security_groups                   = ["${module.ecs_security_group.security_group_id_out}"]
  subnets                           = ["${module.private_subnet_1a.subnet_id_out}","${module.private_subnet_1b.subnet_id_out}"]
  deletion_protection               = "false"
  alb_target_group_name             = "elb"
  aws_access_logs_bucket            = "ecs-elb-logs.com"
  sthree_logs_prefix                = "ecs-lb"
  environment                       = "${var.environment}"
  type                              = "ecs_alb"
  
  #Target Group related parameters
  vpc_id                             =  "${module.vpc.vpc_id_out}"
  target_group_port                  = "443"
  target_group_protocol              = "HTTP"
}

#======= Creating ECS Service=========
module "app_ecs_service" {
  source                        = "../../modules/aws/compute/ecs_service"
  name                          = "app"
  environment                   = "${var.environment}"
  ecs_cluster_arn               = "${module.app_ecs_cluster.ecs_cluster_arn_out}"
  ecs_vpc_id                    = "${module.vpc.vpc_id_out}"
  ecs_subnet_ids                = ["${module.private_subnet_1a.subnet_id_out}","${module.private_subnet_1b.subnet_id_out}"]
  tasks_desired_count           = 2
  tasks_minimum_healthy_percent = 50
  tasks_maximum_percent         = 200
  associate_alb                 = true
  alb_security_group            = "${module.ecs_security_group.security_group_id_out}"
  lb_target_group               = "${module.ecs_alb_loadbalancer.alb_target_group_id_out}"
  
  #Autoscaling parameters
  cluster_name                   = "${module.app_ecs_cluster.ecs_cluster_name_out}"
  desired_count                  = "${var.ecs_asg_desired_count}"
  min_count                      = "${var.ecs_asg_min_count}"
  max_count                      = "${var.ecs_asg_max_count}"
  scale_up_cooldown_seconds      = "${var.ecs_scale_up_cooldown_seconds}"
  scale_down_cooldown_seconds    = "${var.ecs_scale_down_cooldown_seconds}"
}
