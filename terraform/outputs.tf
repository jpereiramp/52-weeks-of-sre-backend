output "app_host_ip" {
  description = "Public IP address of the App host"
  value       = digitalocean_droplet.app_host.ipv4_address
}

output "monitoring_host_ip" {
  description = "Public IP address of the Monitoring host"
  value       = digitalocean_droplet.monitoring_host.ipv4_address
}

output "load_balancer_ip" {
  description = "Public IP address of the Load Balancer (production only)"
  value       = var.environment == "production" ? digitalocean_loadbalancer.app_lb[0].ip : null
}

output "database_host" {
  description = "Database connection host"
  value       = digitalocean_database_cluster.app_db.host
  sensitive   = true
}

output "database_port" {
  description = "Database connection port"
  value       = digitalocean_database_cluster.app_db.port
}

output "vpc_id" {
  description = "ID of the created VPC"
  value       = digitalocean_vpc.app_network.id
}
