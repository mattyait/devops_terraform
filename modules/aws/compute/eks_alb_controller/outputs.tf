output "iam_role_name_out" {
  value = element(concat(aws_iam_role.default_role.*.name, [""]), 0)
}

output "iam_role_id_out" {
  value = element(concat(aws_iam_role.default_role.*.id, [""]), 0)
}

output "iam_role_arn_out" {
  value = element(concat(aws_iam_role.default_role.*.arn, [""]), 0)
}
