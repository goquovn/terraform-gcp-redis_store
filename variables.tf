# ----------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# ----------------------------------------------------------------------------------------------------------------------
variable "vpc_network" {
  description = "A reference (self link) to the VPC network to host the Redis MemoryStore in."
  type        = string
}

# ----------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# ----------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "An arbitrary name for the redis instance."
  type        = string
  default     = "v1"
}

variable "full_name" {
  description = "Full name of the redis instance. For backward-compatibility only. Not recommended for general use."
  type        = string
  default     = ""
}

variable "primary_zone" {
  description = "The zone to launch the redis instance in. Options are \"a\" or \"b\" or \"c\" or \"d\". Defaults to \"a\" zone of the Google provider's region if nothing is specified here. See https://cloud.google.com/compute/docs/regions-zones."
  type        = string
  default     = ""
}

variable "alternate_zone" {
  description = "The zone to launch alternate redis instance in when \"var.service_tier\" is set to be \"STANDARD_HA\". Options are \"a\" or \"b\" or \"c\" or \"d\" - must not be same as \"var.primary_zone\". Defaults to a zone other than \"var.primary_zone\" if nothing is specified here. See https://cloud.google.com/compute/docs/regions-zones."
  type        = string
  default     = ""
}

variable "memory_size_gb" {
  description = "Size of the redis memorystore in GB."
  type        = number
  default     = 1
}

variable "redis_version" {
  description = "The version of Redis software. See https://cloud.google.com/memorystore/docs/redis/supported-versions#current_versions."
  type        = string
  default     = "REDIS_4_0"
}

variable "service_tier" {
  description = "Either \"BASIC\" for standalone or \"STANDARD_HA\" for high-availability. Should provide \"var.alternate_zone_letter\" if the value of this is set to \"STANDARD_HA\"."
  type        = string
  default     = "BASIC"
}

variable "redis_timeout" {
  description = "how long a redis operation is allowed to take before being considered a failure."
  type        = string
  default     = "10m"
}

variable "dns_zone_name" {
  description = "OPTIONAL. Name of DNS zone to access the redis host over a private DNS subdomain instead of a private IP address."
  type        = string
  default     = ""
}

variable "dns_subdomain" {
  description = "A private DNS subdomain over which the redis host maybe accessed. This is disregarded if \"var.dns_zone_name\" is not specified."
  type        = string
  default     = "redis"
}

variable "dns_ttl" {
  description = "The time-to-live of the private DNS record set in seconds."
  type        = number
  default     = 300
}

variable "use_private_g_services" {
  description = "Whether to use the VPC's PRIVATE_SERVICE_ACCESS connection mode (recommended). Setting this to \"true\" requires your VPC network (as specified in \"var.vpc_network\") to have its private services connection (also refered to as g_services) to be enabled. Setting this to \"false\" will use the VPC's 'DIRECT_PEERING' connection mode and will require \"var.ip_cidr_range\" to be specified. See https://cloud.google.com/memorystore/docs/redis/networking#connection_modes"
  type        = bool
  default     = true
}

variable "ip_cidr_range" {
  description = "A /29 IP CIDR block that will be reserved for the Redis MemoryStore. This value will be disregarded if \"var.use_private_g_services\" is set to be 'true'."
  type        = string
  default     = ""
}

variable "auth_enabled" {
  description = "Indicates whether OSS Redis AUTH is enabled for the instance. If set to true AUTH is enabled on the instance. Default value is false meaning AUTH is disabled."
  type        = bool
  default     = false
}