resource "aws_secretsmanager_secret" "secret" {
  count       = "${var.enable == "true" ? 1 : 0}"
  name        = "${var.name}"
  description = "${var.description}"
  tags        = "${merge(var.tags)}"
}

resource "aws_secretsmanager_secret_version" "secret" {
  count         = "${var.enable == "true" ? 1 : 0}"
  secret_id     = "${aws_secretsmanager_secret.secret[0].id}"
  secret_string = "${jsonencode(var.secret_data_values)}"
}
