output "aws_secretsmanager_secret_id_out" {
  value = aws_secretsmanager_secret.secret[0].id
}
