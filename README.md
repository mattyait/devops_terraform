[![Build Status](https://travis-ci.org/mattyait/devops_terraform.svg?branch=master)](https://travis-ci.org/mattyait/devops_terraform)
# devops_terraform

Build the docker image

    docker build -t terraform/terraform:latest -f Dockerfile .

Run the docker container

    docker run -i -d -v $(pwd):/mnt/workspace terraform/terraform:latest

Enter the Container and use it as a Dev Environment

    docker exec -it $(docker ps | grep terraform:latest | awk '{print $1}') bash

Setup the AWS Credentials

    aws configure
    AWS Access Key ID [None]: *********
    AWS Secret Access Key [None]: **********
    Default region name [None]:
    Default output format [Noµne]:

# Customize way of handling multiple environment for this project structure

Cd into the specific environment folder and run the terraform

    cd devops_terraform/env/test
    terraform init -var-file=test.variables.tfvar -backend-config=test.backend.tfvars ../../deployment/
    terraform plan -var-file=test.variables.tfvar ../../deployment
    terraform apply -var-file=test.variables.tfvar ../../deployment

Run specific module

    terraform plan -var-file=test.variables.tfvar -target=module.<module_name> ../../deployment/

## Disable/Skip specific part of infra while terraform apply
To disbale or avoid the execution of any specific terraform file, currenlty need to pass the toggle off/on variable in `test.variables.tfvar` to control the specific part of infra.
For example, below are used to skip the ecs_cluster,ecs_service and codebuild part of infra.

    ecs_cluster_create  = "false"
    ecs_service_create  = "false"
    codebuild_create    = "false"


## General way using terraform
After Setup the Credentials, Initialize the terraform and execute the plan

        terraform fmt
        terraform init
        terraform plan

To Create the Infrastructure apply the terraform changes

        terraform apply

## Terraform way of handling Multiple Environment
Create the multiple workspace in case of handling the multiple env.

    terraform workspace new dev

To list and Select the specification workspace

    terraform workspace list
    terraform workspace select dev



# To destory the created infratstructure

    terraform destroy -var-file=test.variable.tfvars ../../deployment

## Modules
- **vpc** : This is a module to create VPC, Private and all public subnets
- **subnet** : This is use to create subnet resource
- **security_group**: Module use to create security group with security rules
- **route_table**: Module to create route table entry
- **nat_gateway**: module to create nat gateway
- **internet_gateway**: Module to create internet_gateway
- **alb_loadbalancer** : Module for any type of load balancer with listerner and target group
- **alb_target_grp**: Module to create the target group for ALB
- **ecs_cluster**: Module to create ecs cluster with security group, launch configuration and autoscaling group
- **ecs_service**: Module to create full ecs service with task definition and attach to ecs cluster

## Usage

# Security group

    module "ecs_cluster_security_group" {
      source              = "../../modules/aws/network/security_group"
      security_group_name = "${var.ecs_security_group_name}"
      vpc_id              = "${module.vpc.vpc_id_out}"
      environment         = "${var.environment}"
      description         = "ecs_cluster_sg"
      ingress_cidr_blocks = [
        {
            from_port   = 80
            to_port     = 80
            protocol    = "tcp"
            description = "ssh port open"
            cidr_blocks = ["0.0.0.0/0"]
        },
        {
            from_port   = 8080
            to_port     = 8080
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

# Alb load balancer

    module "ecs_alb_loadbalancer" {
      source                            = "../../modules/aws/compute/alb_loadbalancer"
      lb_name                           = "test"
      is_internal_lb                    = "false"
      load_balancer_type                = "application"
      security_groups                   = ["${module.ecs_alb_security_group.security_group_id_out}"]
      subnets                           = ["${module.private_subnet_1a.subnet_id_out}","${module.private_subnet_1b.subnet_id_out}"]
      deletion_protection               = "false"
      alb_target_group_name             = "test"
      environment                       = "${var.environment}"
      type                              = "ecs_alb"

      #Target Group related parameters
      vpc_id                             =  "${module.vpc.vpc_id_out}"
      target_group_port                  = "80"
      target_group_protocol              = "HTTP"
    }

# Ecs cluster

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
      root_volume_size  = "20"
      ebs_volume_size   = "50"
      security_group_ids = ["${module.ecs_cluster_security_group.security_group_id_out}"]
    }

# Ecs service

    module "app_ecs_service" {
      source                        = "../../modules/aws/compute/ecs_service"
      name                          = "test"
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
