data "aws_route53_zone" "default" {
  count        = var.enable ? 1 : 0
  zone_id      = var.parent_zone_id
  name         = var.parent_zone_name
  private_zone = var.private_zone
}

resource "aws_route53_record" "default_CNAME" {
  count   = var.enable && var.recors_set_type == "CNAME" ? length(var.name) : 0
  zone_id = data.aws_route53_zone.default[0].zone_id
  name    = "${var.name[count.index]}.${data.aws_route53_zone.default[0].name}"
  type    = "CNAME"
  ttl     = var.ttl
  records = [var.records[count.index]]
}

resource "aws_route53_record" "default_A" {
  count   = var.enable && var.recors_set_type == "A" && length(var.records) > 0 ? length(var.name) : 0
  zone_id = data.aws_route53_zone.default[0].zone_id
  name    = "${var.name[count.index]}.${data.aws_route53_zone.default[0].name}"
  type    = "A"
  ttl     = var.ttl
  records = [var.records[count.index]]
}

resource "aws_route53_record" "default_A_withAlias" {
  count   = var.enable && var.recors_set_type == "A" && length(var.alias) > 0 ? length(var.name) : 0
  zone_id = data.aws_route53_zone.default[0].zone_id
  name    = "${var.name[count.index]}.${data.aws_route53_zone.default[0].name}"
  type    = "A"

  alias {
    name                   = length(var.alias) > 0 ? element(var.alias["names"], count.index) : ""
    zone_id                = length(var.alias) > 0 ? element(var.alias["zone_ids"], count.index) : ""
    evaluate_target_health = length(var.alias) > 0 ? element(var.alias["evaluate_target_healths"], count.index) : false
  }
}