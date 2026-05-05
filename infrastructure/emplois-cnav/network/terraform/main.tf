terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = ">= 2.60.0"
    }
  }
  required_version = ">= 1.10"
}

resource "scaleway_vpc" "vpc" {
  name = "emplois-cnav-vpc"
}

moved {
  from = scaleway_vpc_private_network.private_network
  to   = scaleway_vpc_private_network.strongswan_private_network
}

resource "scaleway_vpc_private_network" "strongswan_private_network" {
  name                             = "emplois-cnav-strongswan-private-network"
  vpc_id                           = scaleway_vpc.vpc.id
  enable_default_route_propagation = true

  ipv4_subnet {
    subnet = "10.251.0.0/20"
  }
}

resource "scaleway_vpc_private_network" "kubernetes_private_network" {
  name                             = "emplois-cnav-kubernetes-private-network"
  vpc_id                           = scaleway_vpc.vpc.id
  enable_default_route_propagation = true

  ipv4_subnet {
    subnet = "10.252.0.0/20"
  }
}

resource "scaleway_vpc_public_gateway_ip" "strongswan_public_gateway_ip" {
  tags = ["emplois-cnav-strongswan-public-gateway-ip"] # Required for filtering in data sources
}

resource "scaleway_vpc_public_gateway" "strongswan_public_gateway" {
  name            = "strongswan-public-gateway"
  type            = "VPC-GW-S"
  ip_id           = scaleway_vpc_public_gateway_ip.strongswan_public_gateway_ip.id
  bastion_enabled = true
  bastion_port    = 61000
}

resource "scaleway_ipam_ip" "strongswan_public_gateway_private_network_ip" {
  address = "10.251.1.1"

  source {
    private_network_id = scaleway_vpc_private_network.strongswan_private_network.id
  }
}

resource "scaleway_vpc_gateway_network" "strongswan_gateway_network" {
  gateway_id         = scaleway_vpc_public_gateway.strongswan_public_gateway.id
  private_network_id = scaleway_vpc_private_network.strongswan_private_network.id

  ipam_config {
    push_default_route = true
    ipam_ip_id         = scaleway_ipam_ip.strongswan_public_gateway_private_network_ip.id
  }
}

# Public Gateway for Kubernetes cluster
resource "scaleway_vpc_public_gateway_ip" "kubernetes_public_gateway_ip" {
  tags = ["emplois-cnav-kubernetes-public-gateway-ip"]
}

resource "scaleway_vpc_public_gateway" "kubernetes_public_gateway" {
  name  = "kubernetes-public-gateway"
  type  = "VPC-GW-S"
  ip_id = scaleway_vpc_public_gateway_ip.kubernetes_public_gateway_ip.id
}

resource "scaleway_ipam_ip" "kubernetes_public_gateway_private_network_ip" {
  address = "10.252.1.1"

  source {
    private_network_id = scaleway_vpc_private_network.kubernetes_private_network.id
  }
}

resource "scaleway_vpc_gateway_network" "kubernetes_gateway_network" {
  gateway_id         = scaleway_vpc_public_gateway.kubernetes_public_gateway.id
  private_network_id = scaleway_vpc_private_network.kubernetes_private_network.id

  ipam_config {
    push_default_route = true
    ipam_ip_id         = scaleway_ipam_ip.kubernetes_public_gateway_private_network_ip.id
  }
}

resource "scaleway_lb_ip" "traefik_lb_ip" {
  tags = ["emplois-cnav-traefik-lb-ip"]
}

resource "scaleway_lb" "traefik_lb" {
  ip_ids                    = [scaleway_lb_ip.traefik_lb_ip.id]
  name                      = "traefik-lb"
  description               = var.managed
  type                      = "LB-S"
  external_private_networks = true
}

resource "scaleway_lb_private_network" "traefik_lb_private_network" {
  lb_id              = scaleway_lb.traefik_lb.id
  private_network_id = scaleway_vpc_private_network.kubernetes_private_network.id
}

# VPC Routes for inter-Private Network communication
# Allows Kubernetes pods to reach Strongswan and vice-versa

resource "scaleway_vpc_route" "kubernetes_to_strongswan" {
  vpc_id                     = scaleway_vpc.vpc.id
  description                = "Route from Kubernetes PN to Strongswan PN"
  destination                = scaleway_vpc_private_network.strongswan_private_network.ipv4_subnet[0].subnet
  nexthop_private_network_id = scaleway_vpc_private_network.strongswan_private_network.id
}

resource "scaleway_vpc_route" "strongswan_to_kubernetes" {
  vpc_id                     = scaleway_vpc.vpc.id
  description                = "Route from Strongswan PN to Kubernetes PN"
  destination                = scaleway_vpc_private_network.kubernetes_private_network.ipv4_subnet[0].subnet
  nexthop_private_network_id = scaleway_vpc_private_network.kubernetes_private_network.id
}
