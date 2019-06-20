module "eks_cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "2.3.1"
  cluster_version = "1.12"
  cluster_name = "eks_cluster"

  vpc_id = "${module.vpc.vpc_id_out}"
  subnets = ["${module.private_subnet_1a.subnet_id_out}", "${module.private_subnet_1b.subnet_id_out}", "${module.public_subnet_1a.subnet_id_out}", "${module.public_subnet_1b.subnet_id_out}"]


  write_kubeconfig      = true
  config_output_path    = "/.kube/"
  manage_aws_auth       = true
  write_aws_auth_config = true

  worker_groups = [
    {
      instance_type = "m1.medium"
      asg_max_size  = 5
    }
  ]

  tags = {
    Cluster = "k8s"
  }
}