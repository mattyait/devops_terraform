module "eks" {
  count   = var.eks_cluster_create ? 1 : 0
  source  = "terraform-aws-modules/eks/aws"
  version = "19.16.0"

  cluster_name    = "${var.eks_cluster_name}-eks-${var.environment}"
  cluster_version = var.eks_cluster_version

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  # OpenID provider creation (IAM role for service accounts on EKS cluster)
  # true if want to create it via terraform
  enable_irsa                   = true
  kms_key_enable_default_policy = true

  cluster_addons = {
    kube-proxy = {}
    vpc-cni    = {}
    coredns = {
      addon_version = "v1.10.1-eksbuild.2"
      configuration_values = jsonencode({
        computeType = "fargate"
      })
    }
  }

  vpc_id     = module.vpc.vpc_id_out
  subnet_ids = [module.private_subnet_1a.subnet_id_out, module.private_subnet_1b.subnet_id_out]

  # Fargate profiles use the cluster primary security group so these are not utilized
  create_cluster_security_group = false
  create_node_security_group    = false

  fargate_profile_defaults = {
    iam_role_additional_policies = {
      additional = aws_iam_policy.additional.arn
    }
  }

  fargate_profiles = merge(
    {
      devops-eks-profile = {
        name = "devops-eks"
        selectors = [
          {
            namespace = "app-*"
            labels = {
              Application = "app-*"
            }
          }
        ]

        subnet_ids = [module.private_subnet_1a.subnet_id_out, module.private_subnet_1b.subnet_id_out]
        tags       = local.tags
        timeouts = {
          create = "20m"
          delete = "20m"
        }
      }
    },
    { for i in range(3) :
      "kube-system-${element(split("-", local.azs[i]), 2)}" => {
        selectors = [
          { namespace = "kube-system" }
        ]
        # Create a profile per AZ for high availability
        subnet_ids = [element([module.private_subnet_1a.subnet_id_out, module.private_subnet_1b.subnet_id_out], i)]
      }
    }
  )
  cluster_tags = { "alpha.eksctl.io/cluster-oidc-enabled" = "true" }
  tags         = local.tags
}

resource "aws_iam_policy" "additional" {
  name = "eks-additional-${var.environment}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}


data "template_file" "alb_controller_iam_policy" {
  count   = var.eks_cluster_create ? 1 : 0
  template = file("../templates/eks/alb_controller_policy.json.tpl")
}

# Creating AWS ALB Controller on EKS Cluster Fargate
module "eks_alb_controller" {
  count   = var.eks_cluster_create ? 1 : 0
  source                        = "../modules/aws/compute/eks_alb_controller"
  role_name = "${var.environment}_eks_alb_controller"
  policy    = data.template_file.alb_controller_iam_policy[0].rendered

  oidc_providers = {
    main = {
      provider_arn               = "arn:aws:iam::${local.account_id}:oidc-provider/${module.eks[0].oidc_provider}"
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
  aws_region          = var.aws_region
  vpc_id              = module.vpc.vpc_id_out
  eks_cluster_name    = "${var.eks_cluster_name}-eks-${var.environment}"
  tags                = local.tags
}
