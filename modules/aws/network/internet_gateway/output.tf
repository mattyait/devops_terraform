output "internet_gateway_id_out" {
  value = "${aws_internet_gateway.internet_gateway[0].id}"
}
