# outputs produced at the end of a terraform apply
output "vpc_id_out" {
  value = "${aws_vpc.vpc[0].id}"
}
