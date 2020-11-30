locals {
  this_key_name           = element(concat(aws_key_pair.rsa_generated.*.key_name, aws_key_pair.ecdsa_generated.*.key_name, [""]), 0)
  this_public_key_openssh = element(concat(tls_private_key.rsa_generated.*.public_key_openssh, tls_private_key.ecdsa_generated.*.public_key_openssh, [""]), 0)
  this_private_key_pem    = element(concat(tls_private_key.rsa_generated.*.private_key_pem, tls_private_key.ecdsa_generated.*.private_key_pem, [""]), 0)
}
output "key_name" {
  value = local.this_key_name
}

output "public_key_openssh" {
  value = local.this_public_key_openssh
}

output "private_key_pem" {
  value = local.this_private_key_pem
}

output "public_key_filepath" {
  value = local.public_key_filename
}

output "private_key_filepath" {
  value = local.private_key_filename
}