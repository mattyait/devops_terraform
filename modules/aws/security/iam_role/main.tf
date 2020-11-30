data "aws_iam_policy_document" "instance-assume-role-policy" {
  count = var.enable == "true" ? 1 : 0
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = var.trusted_role_services
    }
  }
}

#Creating instamce profile if passing the instance profile name
resource "aws_iam_instance_profile" "aws_iam_instance_profile" {
  count = var.enable == "true" && length(var.iam_instance_profile_name) > 0 ? 1 : 0
  name  = var.iam_instance_profile_name
  role  = aws_iam_role.default_role[0].name
}

resource "aws_iam_role" "default_role" {
  count              = var.enable == "true" ? 1 : 0
  name               = var.role_name
  description        = var.iam_role_description
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy[0].json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "custom" {
  count      = var.enable == "true" && length(var.custom_role_policy_arns) > 0 ? length(var.custom_role_policy_arns) : 0
  role       = aws_iam_role.default_role[0].name
  policy_arn = element(var.custom_role_policy_arns, count.index)
}

resource "aws_iam_role_policy" "policy" {
  count       = var.enable == "true" && var.policy_enabled && var.policy_arn == "" ? 1 : 0
  name        = "${var.role_name}_Policy"
  role       = aws_iam_role.default_role[0].name
  policy      = var.policy
}

resource "aws_iam_role_policy_attachment" "additional_policy" {
  count      = var.enable == "true" && var.policy_enabled && var.policy_arn != "" ? 1 : 0
  role       = aws_iam_role.default_role[0].name
  policy_arn = var.policy_arn
}