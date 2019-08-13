module "eks_cluster" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "5.0.0"
  cluster_version = "${var.eks_cluster_version}"
  cluster_name    = "${var.environment}-${var.eks_cluster_name}"

  vpc_id  = "${module.vpc.vpc_id_out}"
  subnets = ["${module.private_subnet_1a.subnet_id_out}", "${module.private_subnet_1b.subnet_id_out}", "${module.public_subnet_1a.subnet_id_out}", "${module.public_subnet_1b.subnet_id_out}"]

  write_kubeconfig      = true
  config_output_path    = "/.kube/"
  manage_aws_auth       = true
  write_aws_auth_config = true
  map_users             = "${var.eks_cluster_map_users}"

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
      subnets              = ["${module.private_subnet_1a.subnet_id_out}", "${module.private_subnet_1b.subnet_id_out}"]
    },
  ]

  tags = {
    Cluster = "k8s"
  }
}

resource "aws_s3_bucket" "eks_cluster_config" {
  bucket = "${var.environment}-eks-cluster-config"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    Name        = "${var.environment}-eks-cluster-config"
    Environment = "${var.environment}"
  }
}

resource "aws_s3_bucket_object" "eks_config_files" {
  bucket = "${var.environment}-eks-cluster-config"
  key    = "kubeconfig_${var.environment}-${var.eks_cluster_name}"
  source = "/.kube/kubeconfig_${var.environment}-${var.eks_cluster_name}"
}

resource "aws_s3_bucket_object" "eks_auth_files" {
  bucket = "${var.environment}-eks-cluster-config"
  key    = "config-map-aws-auth_${var.environment}-${var.eks_cluster_name}.yaml"
  source = "/.kube/config-map-aws-auth_${var.environment}-${var.eks_cluster_name}.yaml"
}

#====Configuring the kubectl and registering the nodes with EKS cluster===
#resource "null_resource" "configure-kubectl" {
#  depends_on = [module.eks_cluster.cluster_id]
#  provisioner "local-exec" {
#    command = "export KUBECONFIG=$KUBECONFIG:/.kube/kubeconfig_${var.environment}-${var.eks_cluster_name}"
#    #interpreter = ["/bin/bash", "-c"]
#  }
#}


#resource "null_resource" "register-nodes" {
#  depends_on = [null_resource.configure-kubectl]
#  provisioner "local-exec" {
#    command = "kubectl apply -f /.kube/config-map-aws-auth_${var.environment}-${var.eks_cluster_name}.yaml"
#    interpreter = ["/bin/bash", "-c"]
#  }
#}

