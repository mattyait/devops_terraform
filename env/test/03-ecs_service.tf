#======= Creating Security Group needed for ALB for ECS service=========
module "ecs_alb_security_group" {
  source              = "../../modules/aws/network/security_group"
  security_group_name = "${var.ecs_alb_security_group_name}"
  vpc_id              = "${module.vpc.vpc_id_out}"
  environment         = "${var.environment}"
  description         = "test-alb-sg"
  ingress_cidr_blocks = [
    {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        description = "HTTP open for all"
        cidr_blocks = ["0.0.0.0/0"]
    },
    {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        description = "Specific ip"
        cidr_blocks = ["10.20.0.0/16"]
    },
    {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        description = "Https open for all"
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
  lb_name                           = "test-j-api-app"
  is_internal_lb                    = "false"
  load_balancer_type                = "application"
  security_groups                   = ["${module.ecs_alb_security_group.security_group_id_out}"]
  subnets                           = ["${module.public_subnet_1a.subnet_id_out}","${module.public_subnet_1b.subnet_id_out}"]
  deletion_protection               = "false"
  alb_target_group_name             = "test-j-api-app-tg"
  environment                       = "${var.environment}"
  type                              = "ecs_alb"
  
  #Target Group related parameters
  vpc_id                             =  "${module.vpc.vpc_id_out}"
  target_group_port                  = "80"
  target_group_protocol              = "HTTP"
}

#======= Creating ECS Service=========
module "app_ecs_service" {
  source                        = "../../modules/aws/compute/ecs_service"
  name                          = "test-j-api-app"
  environment                   = "${var.environment}"
  ecs_cluster_arn               = "${module.app_ecs_cluster.ecs_cluster_arn_out}"
  ecs_vpc_id                    = "${module.vpc.vpc_id_out}"
  ecs_subnet_ids                = ["${module.private_subnet_1a.subnet_id_out}","${module.private_subnet_1b.subnet_id_out}"]
  tasks_desired_count           = 2
  tasks_minimum_healthy_percent = 50
  tasks_maximum_percent         = 200
  associate_alb                 = true
  alb_security_group            = "${module.ecs_alb_security_group.security_group_id_out}"
  lb_target_group               = "${module.ecs_alb_loadbalancer.alb_target_group_id_out}"
  
  #Autoscaling parameters
  cluster_name                   = "${module.app_ecs_cluster.ecs_cluster_name_out}"
  desired_count                  = "${var.ecs_asg_desired_count}"
  min_count                      = "${var.ecs_asg_min_count}"
  max_count                      = "${var.ecs_asg_max_count}"
  scale_up_cooldown_seconds      = "${var.ecs_scale_up_cooldown_seconds}"
  scale_down_cooldown_seconds    = "${var.ecs_scale_down_cooldown_seconds}"
}

#===== This module will create target group as well as load balancer and attach=====
module "ecs_alb_loadbalancer1" {
  source                            = "../../modules/aws/compute/alb_loadbalancer"
  lb_name                           = "test-j-api-app1"
  is_internal_lb                    = "false"
  load_balancer_type                = "application"
  security_groups                   = ["${module.ecs_alb_security_group.security_group_id_out}"]
  subnets                           = ["${module.public_subnet_1a.subnet_id_out}","${module.public_subnet_1b.subnet_id_out}"]
  deletion_protection               = "false"
  alb_target_group_name             = "test-j-api-app-tg1"
  environment                       = "${var.environment}"
  type                              = "ecs_alb"
  
  #Target Group related parameters
  vpc_id                             =  "${module.vpc.vpc_id_out}"
  target_group_port                  = "80"
  target_group_protocol              = "HTTP"
}

#======= Creating ECS Service=========
module "app_ecs_service1" {
  source                        = "../../modules/aws/compute/ecs_service"
  name                          = "test-j-api-app1"
  environment                   = "${var.environment}"
  ecs_cluster_arn               = "${module.app_ecs_cluster.ecs_cluster_arn_out}"
  ecs_vpc_id                    = "${module.vpc.vpc_id_out}"
  ecs_subnet_ids                = ["${module.private_subnet_1a.subnet_id_out}","${module.private_subnet_1b.subnet_id_out}"]
  tasks_desired_count           = 2
  tasks_minimum_healthy_percent = 50
  tasks_maximum_percent         = 200
  associate_alb                 = true
  alb_security_group            = "${module.ecs_alb_security_group.security_group_id_out}"
  lb_target_group               = "${module.ecs_alb_loadbalancer1.alb_target_group_id_out}"
  
  #Autoscaling parameters
  cluster_name                   = "${module.app_ecs_cluster.ecs_cluster_name_out}"
  desired_count                  = "${var.ecs_asg_desired_count}"
  min_count                      = "${var.ecs_asg_min_count}"
  max_count                      = "${var.ecs_asg_max_count}"
  scale_up_cooldown_seconds      = "${var.ecs_scale_up_cooldown_seconds}"
  scale_down_cooldown_seconds    = "${var.ecs_scale_down_cooldown_seconds}"
}