output "usage_IAM_roles" {
  description = "Basic IAM role(s) that are generally necessary for using the resources in this module. See https://cloud.google.com/iam/docs/understanding-roles."
  value = [
    "roles/redis.editor",
  ]
}

output "host_ip" {
  description = "Private IP address of the Redis host"
  value       = google_redis_instance.redis_store.host
}

output "host_dns" {
  description = "Private DNS address of the Redis host"
  value       = local.create_private_dns ? trimsuffix(google_dns_record_set.redis_subdomain.0.name, ".") : null
}

output "port" {
  description = "Port number of the Redis endpoint."
  value       = google_redis_instance.redis_store.port
}