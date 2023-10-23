data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
  region     = data.aws_region.current.name
}

data "aws_iam_policy_document" "this" {
  count = var.create_role ? 1 : 0
  dynamic "statement" {
    for_each = var.allow_self_assume_role ? [1] : []

    content {
      sid     = "ExplicitSelfRoleAssumption"
      effect  = "Allow"
      actions = ["sts:AssumeRole"]

      principals {
        type        = var.principals_type
        identifiers = var.trusted_role_services
      }

      condition {
        test     = "ArnLike"
        variable = "aws:PrincipalArn"
        values   = ["arn:${local.partition}:iam::${local.account_id}:role/${var.role_name}"]
      }
    }
  }

  # https://aws.amazon.com/premiumsupport/knowledge-center/eks-troubleshoot-oidc-and-irsa/?nc1=h_ls
  dynamic "statement" {
    for_each = var.oidc_providers
    content {
      effect  = "Allow"
      actions = ["sts:AssumeRoleWithWebIdentity"]

      principals {
        type        = "Federated"
        identifiers = [statement.value.provider_arn]
      }

      condition {
        test     = var.assume_role_condition_test
        variable = "${replace(statement.value.provider_arn, "/^(.*provider/)/", "")}:sub"
        values   = [for sa in statement.value.namespace_service_accounts : "system:serviceaccount:${sa}"]
      }

      condition {
        test     = var.assume_role_condition_test
        variable = "${replace(statement.value.provider_arn, "/^(.*provider/)/", "")}:aud"
        values   = ["sts.amazonaws.com"]
      }

    }
  }
}

resource "aws_iam_role" "default_role" {
  name                 = var.role_name
  description          = var.iam_role_description
  assume_role_policy   = data.aws_iam_policy_document.this[0].json
  max_session_duration = var.max_session_duration
  tags                 = var.tags
}

resource "aws_iam_role_policy_attachment" "custom" {
  count      = length(var.custom_role_policy_arns) > 0 ? length(var.custom_role_policy_arns) : 0
  role       = aws_iam_role.default_role.name
  policy_arn = element(var.custom_role_policy_arns, count.index)
}

resource "aws_iam_policy" "policy" {
  count       = var.policy != "" ? 1 : 0
  name        = "${var.role_name}_policy"
  description = var.policy_description
  policy      = var.policy
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  count      = var.policy != "" ? 1 : 0
  role       = aws_iam_role.default_role.name
  policy_arn = aws_iam_policy.policy[0].arn
}

resource "kubernetes_service_account" "service-account" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
      "app.kubernetes.io/component" = "controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn"               = aws_iam_role.default_role.arn
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
  }
}


resource "helm_release" "alb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  depends_on = [
    kubernetes_service_account.service-account
  ]

  set {
    name  = "region"
    value = var.aws_region
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "clusterName"
    value = var.eks_cluster_name
  }

  set {
    name  = "enableShield"
    value = false
  }

  set {
    name  = "enableWaf"
    value = false
  }

  set {
    name  = "enableWafv2"
    value = false
  }

  set {
    name  = "logLevel"
    value = "info"
  }
}
