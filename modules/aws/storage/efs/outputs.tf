output "efs_id_out" {
  value = aws_efs_file_system.default[0].id
}

output "efs_arn_out" {
  value = aws_efs_file_system.default[0].arn
}

output "efs_dns_name_out" {
  value = aws_efs_file_system.default[0].dns_name
}