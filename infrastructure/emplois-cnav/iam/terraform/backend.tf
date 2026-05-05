terraform {
  backend "s3" {
    bucket                      = "gip-inclusion-state"
    key                         = "emplois-cnav/iam/terraform/terraform.tfstate"
    region                      = "fr-par"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    endpoints = {
      s3 = "https://s3.fr-par.scw.cloud"
    }
  }
}
