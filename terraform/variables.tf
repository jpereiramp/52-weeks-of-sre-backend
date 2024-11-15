variable "do_token" {
  description = "DigitalOcean API Token with write access"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "DigitalOcean region for resource deployment"
  type        = string
  default     = "nyc1"

  validation {
    condition     = can(regex("^[a-z]{3}[1-3]$", var.region))
    error_message = "Region must be a valid DigitalOcean region code (e.g., nyc1, sfo2, etc.)"
  }
}

variable "environment" {
  description = "Environment name (staging/production)"
  type        = string
  default     = "staging"

  validation {
    condition     = contains(["staging", "production"], var.environment)
    error_message = "Environment must be either 'staging' or 'production'"
  }
}

variable "ssh_key_fingerprint" {
  description = "SSH key fingerprint for Droplet access"
  type        = string
}

variable "app_droplet_size" {
  description = "Size of the App host droplet"
  type        = string
  default     = "s-1vcpu-1gb"
}

variable "monitoring_droplet_size" {
  description = "Size of the Monitoring host droplet"
  type        = string
  default     = "s-1vcpu-1gb"
}

variable "db_size" {
  description = "Size of the database cluster"
  type        = string
  default     = "db-s-1vcpu-1gb"
}
