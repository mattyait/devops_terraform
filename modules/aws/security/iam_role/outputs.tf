output "iam_role_name_out" {
  value = aws_iam_role.default_role[0].name
}

output "iam_role_id_out" {
  value = aws_iam_role.default_role[0].id
}

output "iam_role_arn_out" {
  value = aws_iam_role.default_role[0].arn
}

output "iam_instance_profile_name_out" {
  value = aws_iam_instance_profile.aws_iam_instance_profile[0].name
}

output "iam_instance_profile_id_out" {
  value = aws_iam_instance_profile.aws_iam_instance_profile[0].id
}

output "iam_instance_profile_arn_out" {
  value = aws_iam_instance_profile.aws_iam_instance_profile[0].arn
}