data "scaleway_account_project" "iac_gip_inclusion" {
  name     = "iac-gip-inclusion"
  provider = scaleway.tmp
}

data "scaleway_lb" "traefik_lb" {
  name = "traefik-lb"
}
