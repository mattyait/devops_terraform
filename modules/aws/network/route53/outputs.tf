locals {
  this_hostnames = element(concat(aws_route53_record.default_A.*.fqdn, aws_route53_record.default_CNAME.*.fqdn, [""]), 0)
  this_dns       = element(concat(aws_route53_record.default_A.*.name, aws_route53_record.default_CNAME.*.name, [""]), 0)
}

output "hostnames" {
  description = "List of DNS records"
  value       = local.this_hostnames
}

output "dns_name" {
  description = "List of DNS records"
  value       = local.this_hostnames
}

output "parent_zone_id" {
  value       = data.aws_route53_zone.default.*.zone_id
  description = "ID of the hosted zone to contain the records"
}

output "parent_zone_name" {
  value       = data.aws_route53_zone.default.*.name
  description = "Name of the hosted zone to contain the records"
}