locals {
  public_key_filename  = "${var.path}/${var.name}.pub"
  private_key_filename = "${var.path}/${var.name}.pem"
}

resource "tls_private_key" "rsa_generated" {
  count     = var.algorithm == "RSA" ? 1 : 0
  algorithm = var.algorithm
  rsa_bits  = var.curve
}

resource "tls_private_key" "ecdsa_generated" {
  count       = var.algorithm == "ECDSA" ? 1 : 0
  algorithm   = var.algorithm
  ecdsa_curve = var.curve
}

resource "aws_key_pair" "rsa_generated" {
  count      = var.algorithm == "RSA" ? 1 : 0
  key_name   = var.name
  public_key = tls_private_key.rsa_generated[0].public_key_openssh

  lifecycle {
    ignore_changes = [key_name]
  }
}

resource "aws_key_pair" "ecdsa_generated" {
  count      = var.algorithm == "ECDSA" ? 1 : 0
  key_name   = var.name
  public_key = tls_private_key.ecdsa_generated[0].public_key_openssh

  lifecycle {
    ignore_changes = [key_name]
  }
}

resource "local_file" "rsa_public_key_openssh" {
  count    = var.path != "" && var.algorithm == "RSA" ? 1 : 0
  content  = tls_private_key.rsa_generated[0].public_key_openssh
  filename = local.public_key_filename
}

resource "local_file" "ecdsa_public_key_openssh" {
  count    = var.path != "" && var.algorithm == "ECDSA" ? 1 : 0
  content  = tls_private_key.ecdsa_generated[0].public_key_openssh
  filename = local.public_key_filename
}

resource "local_file" "rsa_private_key_pem" {
  count    = var.path != "" && var.algorithm == "RSA" ? 1 : 0
  sensitive_content  = tls_private_key.rsa_generated[0].private_key_pem
  filename = local.private_key_filename
}

resource "local_file" "ecsdsa_private_key_pem" {
  count    = var.path != "" && var.algorithm == "ECDSA" ? 1 : 0
  sensitive_content  = tls_private_key.ecdsa_generated[0].private_key_pem
  filename = local.private_key_filename
}

resource "null_resource" "rsa_chmod" {
  count      = var.path != "" && var.algorithm == "RSA" ? 1 : 0
  depends_on = [local_file.rsa_private_key_pem]

  triggers = {
    key = tls_private_key.rsa_generated[0].private_key_pem
  }

  provisioner "local-exec" {
    command = "chmod 600 ${local.private_key_filename}"
  }
}

resource "null_resource" "ecdsa_chmod" {
  count      = var.path != "" && var.algorithm == "ECDSA" ? 1 : 0
  depends_on = [local_file.ecsdsa_private_key_pem]

  triggers = {
    key = tls_private_key.ecdsa_generated[0].private_key_pem
  }

  provisioner "local-exec" {
    command = "chmod 600 ${local.private_key_filename}"
  }
}