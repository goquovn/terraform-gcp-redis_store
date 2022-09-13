resource "random_string" "name_suffix" {
  length  = 6
  upper   = false
  special = false
}
locals {
  memory_store_name = (
    var.full_name != ""
    ?
    format("%s-%s", var.full_name, random_string.name_suffix.result)
    :
    format("redis-%s-%s", var.name, random_string.name_suffix.result)
  )
  memory_store_display_name = "Redis generated by Terraform ${random_string.name_suffix.result}"
  region                    = data.google_client_config.google_client.region

  # determine a primary zone if it is not provided
  primary_zone_letter = var.primary_zone == "" ? "a" : var.primary_zone
  primary_zone        = "${local.region}-${local.primary_zone_letter}"

  # determine an alternate zone if it is not provided
  all_zone_letters       = ["a", "b", "c", "d"]
  remaining_zone_letters = tolist(setsubtract(toset(local.all_zone_letters), toset([local.primary_zone_letter])))
  alternate_zone_letter  = var.alternate_zone == "" ? local.remaining_zone_letters.0 : var.alternate_zone
  alternate_zone         = "${local.region}-${local.alternate_zone_letter}"

  # Determine connection mode and IP ranges
  connect_mode  = var.use_private_g_services ? "PRIVATE_SERVICE_ACCESS" : "DIRECT_PEERING"
  ip_cidr_range = var.use_private_g_services ? null : var.ip_cidr_range

  # DNS
  create_private_dns = var.dns_zone_name == "" ? false : true
}

data "google_client_config" "google_client" {}

resource "google_project_service" "redis_api" {
  service            = "redis.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "dns_api" {
  service            = "dns.googleapis.com"
  disable_on_destroy = false
}

resource "google_redis_instance" "redis_store" {
  name                    = local.memory_store_name
  memory_size_gb          = var.memory_size_gb
  display_name            = local.memory_store_display_name
  redis_version           = var.redis_version
  tier                    = var.service_tier
  authorized_network      = var.vpc_network
  region                  = local.region
  location_id             = local.primary_zone
  auth_enabled            = var.auth_enabled
  alternative_location_id = var.service_tier == "STANDARD_HA" ? local.alternate_zone : null
  connect_mode            = local.connect_mode
  reserved_ip_range       = local.ip_cidr_range
  depends_on              = [google_project_service.redis_api]
  timeouts {
    create = var.redis_timeout
    update = var.redis_timeout
    delete = var.redis_timeout
  }
}

resource "google_dns_record_set" "redis_subdomain" {
  count        = local.create_private_dns ? 1 : 0
  managed_zone = var.dns_zone_name
  name         = format("%s.%s", var.dns_subdomain, data.google_dns_managed_zone.dns_zone.dns_name)
  type         = "A"
  rrdatas      = [google_redis_instance.redis_store.host]
  ttl          = var.dns_ttl
}

data "google_dns_managed_zone" "dns_zone" {
  name       = var.dns_zone_name
  depends_on = [google_project_service.dns_api]
}
