terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

# VPC for network isolation
resource "digitalocean_vpc" "app_network" {
  name   = "app-network-${var.environment}"
  region = var.region
}

# Application Droplet
resource "digitalocean_droplet" "app_host" {
  name     = "app-host-${var.environment}"
  size     = var.app_droplet_size
  image    = "ubuntu-22-04-x64"
  region   = var.region
  vpc_uuid = digitalocean_vpc.app_network.id
  ssh_keys = [var.ssh_key_fingerprint]

  tags = ["app-host", var.environment]

  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
  }
}

# Monitoring Droplet
resource "digitalocean_droplet" "monitoring_host" {
  name     = "monitoring-host-${var.environment}"
  size     = var.monitoring_droplet_size
  image    = "ubuntu-22-04-x64"
  region   = var.region
  vpc_uuid = digitalocean_vpc.app_network.id
  ssh_keys = [var.ssh_key_fingerprint]

  tags = ["monitoring-host", var.environment]

  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
  }
}

# Managed PostgreSQL Database
resource "digitalocean_database_cluster" "app_db" {
  name       = "app-db-${var.environment}"
  engine     = "pg"
  version    = "14"
  size       = var.db_size
  region     = var.region
  node_count = var.environment == "production" ? 3 : 1

  maintenance_window {
    day  = "sunday"
    hour = "02:00:00"
  }
}

# Database Firewall Rules
resource "digitalocean_database_firewall" "app_db_fw" {
  cluster_id = digitalocean_database_cluster.app_db.id

  # Allow access from App host
  rule {
    type  = "droplet"
    value = digitalocean_droplet.app_host.id
  }
}

# Load Balancer for production environment
resource "digitalocean_loadbalancer" "app_lb" {
  count  = var.environment == "production" ? 1 : 0
  name   = "app-lb-${var.environment}"
  region = var.region

  vpc_uuid = digitalocean_vpc.app_network.id

  forwarding_rule {
    entry_port      = 80
    entry_protocol  = "http"
    target_port     = 8080
    target_protocol = "http"
  }

  healthcheck {
    port     = 8080
    protocol = "http"
    path     = "/health"
  }

  droplet_ids = [digitalocean_droplet.app_host.id]
}

# Firewall rules for App host
resource "digitalocean_firewall" "app_firewall" {
  name = "app-firewall-${var.environment}"

  droplet_ids = [digitalocean_droplet.app_host.id]

  inbound_rule {
    protocol   = "tcp"
    port_range = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol   = "tcp"
    port_range = "8080"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol = "tcp"
    port_range = "1-65535"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
}

# Firewall rules for Monitoring host
resource "digitalocean_firewall" "monitoring_firewall" {
  name = "monitoring-firewall-${var.environment}"

  droplet_ids = [digitalocean_droplet.monitoring_host.id]

  inbound_rule {
    protocol   = "tcp"
    port_range = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol = "tcp"
    port_range = "3000"  # Grafana
    source_addresses = ["0.0.0.0/0", "::/0"] # Allow connections from anywhere
  }

  inbound_rule {
    protocol = "tcp"
    port_range = "9090"  # Prometheus
    source_addresses = [digitalocean_vpc.app_network.ip_range] # Only allow connections from VPC
  }

  outbound_rule {
    protocol = "tcp"
    port_range = "1-65535"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
}
