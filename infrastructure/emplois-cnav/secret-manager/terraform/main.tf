terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = ">= 2.60.0"
    }
  }
  required_version = ">= 1.10"
}

resource "scaleway_secret" "cnav_vpn_config" {
  name        = "cnav-vpn-config"
  protected   = true
  description = var.managed
  type        = "key_value"
}

resource "scaleway_secret" "argocd_oidc" {
  name        = "argocd-oidc"
  protected   = true
  description = var.managed
  type        = "key_value"
}

resource "scaleway_secret" "authentik" {
  name        = "authentik"
  protected   = true
  description = var.managed
  type        = "key_value"
}
