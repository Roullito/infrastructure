data "scaleway_account_project" "emplois_cnav" {
  name     = "emplois-cnav"
  provider = scaleway.tmp
}

data "scaleway_iam_ssh_key" "leo_rsa" {
  name = "leo-rsa"
}
