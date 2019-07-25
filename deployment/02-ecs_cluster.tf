#======= Creating Security Group needed to attach Ec2 instance as a part of cluster=========
module "ecs_cluster_security_group" {
  source              = "../modules/aws/network/security_group"
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
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "ssh port open"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 32768
      to_port     = 61000
      protocol    = "tcp"
      description = "Application port"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  egress_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow outgoing traffic"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

#======= Creating ECS Cluster=========
#It will create Autoscaling group and launch configuration also
module "app_ecs_cluster" {
  source             = "../modules/aws/compute/ecs_cluster"
  ecs_cluster_name   = "${var.ecs_cluster_name}"
  vpc_id             = "${module.vpc.vpc_id_out}"
  environment        = "${var.environment}"
  image_id           = "${var.ecs_ec2_ami}"
  instance_type      = "${var.ecs_ec2_instance_type}"
  subnet_ids         = ["${module.private_subnet_1a.subnet_id_out},${module.private_subnet_1b.subnet_id_out}"]
  desired_capacity   = "${var.ecs_ec2_desired_capacity}"
  max_size           = "${var.ecs_ec2_max_size}"
  min_size           = "${var.ecs_ec2_min_size}"
  key_name           = "${var.key_name}"
  root_volume_size   = "${var.ec2_root_volume_size}"
  ebs_volume_size    = "${var.ec2_ebs_volume_size}"
  security_group_ids = ["${module.ecs_cluster_security_group.security_group_id_out}"]
}