module "aws-secrets-manager" {
  enable             = "${var.aws_secret_create}"
  source             = "../modules/aws/security/secret-manager"
  name               = "demo-${var.environment}-sm"
  description        = "Secret for demo application for ${var.environment} environment"
  secret_data_values = "${var.secret_values}"

  tags = {
    Name        = "demo-${var.environment}-sm"
    Environment = "${var.environment}"
    Created_By  = "${var.created_by}"
  }
}
