module "eks_cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "2.3.1"
  cluster_version = "1.12"
  cluster_name = "eks_cluster"

  vpc_id = "${module.vpc.vpc_id_out}"
  subnets = ["${module.private_subnet_1a.subnet_id_out}", "${module.private_subnet_1b.subnet_id_out}", "${module.public_subnet_1a.subnet_id_out}", "${module.public_subnet_1b.subnet_id_out}"]


  write_kubeconfig      = true
  config_output_path    = "~/.kube/"
  manage_aws_auth       = true
  write_aws_auth_config = true

  worker_groups = [
    {
      name                 = "eks_workers"
      instance_type        = "${var.instance_type}"
      asg_min_size         = "${var.asg_min_size}"
      asg_desired_capacity = "${var.asg_desired_capacity}"
      asg_max_size         = "${var.asg_max_size}"
      root_volume_size     = "${var.root_volume_size}"
      root_volume_type     = "${var.root_volume_type}"
      ami_id               = "${var.ami_id}"
      ebs_optimized        = false
      key_name             = "${var.key_name}"
      enable_monitoring    = false
    }
  ]

  tags = {
    Cluster = "k8s"
    Name = "${var.environment}_eks_workers"
  }
}