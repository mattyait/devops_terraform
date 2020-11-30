variable "aliases" {
  type        = list(string)
  default     = []
  description = "List of aliases"
}

variable "name" {
  type        = list(string)
  default     = []
  description = "Name of the record set for non-alias records"
}

# variable "name" {
#   type        = string
#   description = "Name of the record set for non-alias records"
# }

variable "parent_zone_id" {
  type        = string
  default     = ""
  description = "ID of the hosted zone to contain this record  (or specify `parent_zone_name`)"
}

variable "parent_zone_name" {
  type        = string
  default     = ""
  description = "Name of the hosted zone to contain this record (or specify `parent_zone_id`)"
}

variable "private_zone" {
  type        = bool
  default     = false
  description = "Is this a private hosted zone?"
}

variable "target_dns_name" {
  type        = string
  default     = ""
  description = "DNS name of target resource (e.g. ALB, ELB)"
}

variable "target_zone_id" {
  type        = string
  default     = ""
  description = "ID of target resource (e.g. ALB, ELB)"
}

variable "evaluate_target_health" {
  type        = bool
  default     = false
  description = "Set to true if you want Route 53 to determine whether to respond to DNS queries"
}

variable "enable" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating any resources"
}

variable "allow_overwrite" {
  type        = bool
  default     = false
  description = "Allow creation of this record in Terraform to overwrite an existing record, if any. This does not affect the ability to update the record in Terraform and does not prevent other resources within Terraform or manual Route 53 changes outside Terraform from overwriting this record. false by default. This configuration is not recommended for most environments"
}
variable "recors_set_type" {
  type        = string
  default     = "A"
  description = "Record Set type for DNS record"
}
variable "ttl" {
  type        = string
  default     = "60"
  description = "TTL time for DNS in route53"
}

variable "records" {
  type        = list(string)
  default     = []
  description = "List of records for non alias record"
}

variable "alias" {
  type        = map
  default     = { "names" = [], "zone_ids" = [], "evaluate_target_healths" = [] }
  description = "An alias block. Conflicts with ttl & records. Alias record documented below."
}