terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = ">= 2.55.0"
    }
  }
  required_version = ">= 1.10"
}

module "dns-emplois-cnav" {
  source = "../../../../_modules/dns/records/terraform"

  scw_region     = var.scw_region
  scw_zone       = var.scw_zone
  scw_project_id = data.scaleway_account_project.iac_gip_inclusion.project_id

  records = {
    "argocd" = {
      name = "argocd.interops-a"
      data = data.scaleway_lb.traefik_lb.ip_address
      type = "A"
      ttl  = 300
    },
    "traefik" = {
      name = "traefik.interops-a"
      data = data.scaleway_lb.traefik_lb.ip_address
      type = "A"
      ttl  = 300
    },
    "admin-integration" = {
      name = "admin.integration.interops-a"
      data = data.scaleway_lb.traefik_lb.ip_address
      type = "A"
      ttl  = 300
    },
    "admin-production" = {
      name = "admin.production.interops-a"
      data = data.scaleway_lb.traefik_lb.ip_address
      type = "A"
      ttl  = 300
    },
    "auth" = {
      name = "auth.interops-a"
      data = data.scaleway_lb.traefik_lb.ip_address
      type = "A"
      ttl  = 300
    },
    "certigna-caa-cnav-emplois" = {
      name = "cnav.emplois"
      data = "0 issue \"certigna.fr\""
      type = "CAA"
    },
    "certigna-caa-interops-a" = {
      name = "interops-a"
      data = "0 issue \"certigna.fr\""
      type = "CAA"
    },
    "certigna-claim-1" = {
      name = "_f1497113fd114e567c7010fa49161e07.cnav.emplois"
      data = "c98dc34cd966ac9625499a6c4974db14.7044c2f7aef40335782f94d68be87965.certigna.com."
      type = "CNAME"
    },
    "certigna-claim-2" = {
      name = "_f1497113fd114e567c7010fa49161e07.production.cnav.emplois"
      data = "c98dc34cd966ac9625499a6c4974db14.7044c2f7aef40335782f94d68be87965.certigna.com."
      type = "CNAME"
    },
    "certigna-claim-3" = {
      name = "_f1497113fd114e567c7010fa49161e07.integration.cnav.emplois"
      data = "c98dc34cd966ac9625499a6c4974db14.7044c2f7aef40335782f94d68be87965.certigna.com."
      type = "CNAME"
    },
    "certigna-claim-4" = {
      name = "_f1497113fd114e567c7010fa49161e07.interops-a"
      data = "c98dc34cd966ac9625499a6c4974db14.7044c2f7aef40335782f94d68be87965.certigna.com."
      type = "CNAME"
    },
    "certigna-claim-5" = {
      name = "_f1497113fd114e567c7010fa49161e07.production.interops-a"
      data = "c98dc34cd966ac9625499a6c4974db14.7044c2f7aef40335782f94d68be87965.certigna.com."
      type = "CNAME"
    },
    "certigna-claim-6" = {
      name = "_f1497113fd114e567c7010fa49161e07.integration.interops-a"
      data = "c98dc34cd966ac9625499a6c4974db14.7044c2f7aef40335782f94d68be87965.certigna.com."
      type = "CNAME"
    },
    "certigna-claim-7" = {
      name = "_f1497113fd114e567c7010fa49161e07.ws-ident.interops-a"
      data = "c98dc34cd966ac9625499a6c4974db14.7044c2f7aef40335782f94d68be87965.certigna.com."
      type = "CNAME"
    },
    "certigna-claim-8" = {
      name = "_f1497113fd114e567c7010fa49161e07.ws-ident.production.interops-a"
      data = "c98dc34cd966ac9625499a6c4974db14.7044c2f7aef40335782f94d68be87965.certigna.com."
      type = "CNAME"
    },
    "certigna-claim-9" = {
      name = "_f1497113fd114e567c7010fa49161e07.ws-ident.integration.interops-a"
      data = "c98dc34cd966ac9625499a6c4974db14.7044c2f7aef40335782f94d68be87965.certigna.com."
      type = "CNAME"
    }
  }
}
