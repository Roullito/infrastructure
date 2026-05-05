terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = ">= 2.60.0"
    }
  }
  required_version = ">= 1.10"
}

resource "scaleway_instance_security_group" "strongswan_security_group" {
  name                    = "strongswan-security-group"
  description             = var.managed
  stateful                = true
  inbound_default_policy  = "drop"
  outbound_default_policy = "drop"

  # Cloudflare DNS
  outbound_rule {
    action   = "accept"
    port     = 53
    protocol = "UDP"
    ip_range = "1.1.1.1/32"
  }

  outbound_rule {
    action   = "accept"
    port     = 53
    protocol = "UDP"
    ip_range = "1.0.0.1/32"
  }

  # Scaleway private DNS (VPC resource resolution)
  outbound_rule {
    action   = "accept"
    port     = 53
    protocol = "UDP"
    ip_range = "169.254.169.254/32"
  }

  # Debian repos (HTTPS deb.debian.org / security.debian.org via Fastly)
  outbound_rule {
    action   = "accept"
    port     = 443
    protocol = "TCP"
    ip_range = "151.101.0.0/16"
  }

  # Scaleway PPA (HTTP via ppa.launchpad.net)
  outbound_rule {
    action   = "accept"
    port     = 80
    protocol = "TCP"
    ip_range = "185.125.190.80/32"
  }

  # IKE (key exchange)
  inbound_rule {
    action   = "accept"
    port     = 500
    protocol = "UDP"
  }

  # NAT-T (NAT traversal)
  inbound_rule {
    action   = "accept"
    port     = 4500
    protocol = "UDP"
  }

  # Traffic from Private Network (K8s pods)
  inbound_rule {
    action   = "accept"
    protocol = "ANY"
    ip_range = one(data.scaleway_vpc_private_network.strongswan_private_network.ipv4_subnet).subnet
  }

  # IPSec to CNAV - IKE
  outbound_rule {
    action   = "accept"
    port     = 500
    protocol = "UDP"
    ip_range = "${local.vpn_config.remote_ip}/32"
  }

  # IPSec to CNAV - NAT-T
  outbound_rule {
    action   = "accept"
    port     = 4500
    protocol = "UDP"
    ip_range = "${local.vpn_config.remote_ip}/32"
  }

  # Traffic to Private Network (K8s pods)
  outbound_rule {
    action   = "accept"
    protocol = "ANY"
    ip_range = one(data.scaleway_vpc_private_network.strongswan_private_network.ipv4_subnet).subnet
  }
}

resource "scaleway_instance_server" "strongswan_instance" {
  name              = "strongswan-vpn"
  type              = "DEV1-S"
  image             = "debian_bookworm"
  security_group_id = scaleway_instance_security_group.strongswan_security_group.id

  root_volume {
    size_in_gb = 20
  }

  user_data = {
    cloud-init = <<-EOT
  #cloud-config
  ${yamlencode(local.instance_user_data)}
  EOT
  }
}

resource "scaleway_ipam_ip" "strongswan_instance_private_network_ip" {
  address = "10.251.9.1"

  source {
    private_network_id = data.scaleway_vpc_private_network.strongswan_private_network.id
  }
}

resource "scaleway_ipam_ip" "interops_integration_ip" {
  address = local.vpn_config.local_ip_integration

  source {
    private_network_id = data.scaleway_vpc_private_network.strongswan_private_network.id
  }
}

resource "scaleway_ipam_ip" "interops_production_ip" {
  address = local.vpn_config.local_ip_production

  source {
    private_network_id = data.scaleway_vpc_private_network.strongswan_private_network.id
  }
}

resource "scaleway_instance_private_nic" "strongswan_instance_private_nic" {
  private_network_id = data.scaleway_vpc_private_network.strongswan_private_network.id
  server_id          = scaleway_instance_server.strongswan_instance.id
  ipam_ip_ids = [
    scaleway_ipam_ip.strongswan_instance_private_network_ip.id,
    scaleway_ipam_ip.interops_integration_ip.id,
    scaleway_ipam_ip.interops_production_ip.id,
  ]
}

resource "scaleway_vpc_public_gateway_pat_rule" "ipsec_ike" {
  gateway_id   = data.scaleway_vpc_public_gateway.strongswan_public_gateway.id
  private_ip   = scaleway_ipam_ip.strongswan_instance_private_network_ip.address
  private_port = 500
  public_port  = 500
  protocol     = "udp"
}

resource "scaleway_vpc_public_gateway_pat_rule" "ipsec_nat_t" {
  gateway_id   = data.scaleway_vpc_public_gateway.strongswan_public_gateway.id
  private_ip   = scaleway_ipam_ip.strongswan_instance_private_network_ip.address
  private_port = 4500
  public_port  = 4500
  protocol     = "udp"
}
