data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = var.trusted_role_arns
    }
  }
}

resource "aws_iam_role" "iam_role" {
    name = "${var.iam_role_name}"
    assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy_attachment" "ecs_services_policy" {
    name = "ecs_services_policy-${var.environment}"
    roles = ["${aws_iam_role.iam_role.name}"]
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}