data "scaleway_account_project" "emplois_cnav" {
  name     = "emplois-cnav"
  provider = scaleway.tmp
}

data "scaleway_vpc_private_network" "strongswan_private_network" {
  name = "emplois-cnav-strongswan-private-network"
}

data "scaleway_vpc_public_gateway" "strongswan_public_gateway" {
  name = "strongswan-public-gateway"
}

data "scaleway_secret_version" "cnav_vpn_config" {
  secret_name = "cnav-vpn-config"
  revision    = "latest_enabled"
  project_id  = data.scaleway_account_project.emplois_cnav.id
}

data "scaleway_vpc_public_gateway_ip" "strongswan_public_gateway_ip" {
  ip_id = local.strongswan_public_gateway_ip.id # FIXME
}
