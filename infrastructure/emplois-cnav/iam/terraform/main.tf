terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = ">= 2.60.0"
    }
  }
  required_version = ">= 1.10"
}

resource "scaleway_iam_ssh_key" "leo" {
  name       = "leo"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKEL9IfV8A/AssY0xT7MamKHag/x5U5SKuSf7fFw+kP5"
}

resource "scaleway_iam_ssh_key" "leo_rsa" {
  name       = "leo-rsa"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC2zhD56mL9suju4sXrge87ESpQgaQmZsgPas7rVmDCX+WKAbZEiMrro7qERho+pTaq5IpC3JEUUTPHriIMKQoWi3+IDANPcZwcVc6LOtGp3LHlDM9OBe/4nduUjMfhE2u1Bf01ekMLGUWDe4q6yEFF4jsDsWt46062TXUWZvY2PUzxkKVbJ7/D/xu7oXoBV6tb+0fnvLXof7nZ2HlBAfo2uoKF9sNeyfBhKE5naeqYsSw0CCB4qxDxsftRYg1vn1xb8CD/8fN3+c1t1naLLML18MkZdQepqVA0fK2gEpJncVuWFIQtb55fqrQNorpC3YoIkQ9ArzGmSdPfZv1j5cRoUmM62sMiijvuaQAUk32LCtFd16Qo8Gyrhfifm/6lY2GzO1loEwPxNyE9zXOuuxJHEBFX2sFza/Ze/5nX5AxYHtLhq1uHWkOrYqZIlTgnBJkjwCFj0trjLRShtD+SfAqnRgjlbzNtCBF1z+0SabVAvygug0dbeBEhVf6w7UZ/GqLO7+TCZF7d3Z1JS6afsN319yMH3VNl4U7H1q+jU1HYcR2SusTribV9dx52186hFOpDeV9rRGIbSrGrB4m4q1UFxyFZ595VeaXWdDIX/z5X3YGRoTYaWYHOHNHMPL7U1OC9sZke86TPYjUgUGvrRifDW7F4iOoJLpvE/YvqrrXR1Q=="
}

# Kubernetes cluster IAM Application
# Used by External Secrets Operator and for pulling images from Container Registry.
# The API key must be created manually via Scaleway console to avoid storing secrets in Terraform state.
# See emplois-cnav-ops README for bootstrap instructions.
resource "scaleway_iam_application" "kubernetes" {
  name            = "emplois-cnav-kubernetes"
  description     = var.managed
  organization_id = data.scaleway_account_project.emplois_cnav.organization_id
}

# Kubernetes cluster - Policy for reading secrets and pulling container images
resource "scaleway_iam_policy" "kubernetes_readonly" {
  name           = "emplois-cnav-kubernetes-readonly"
  application_id = scaleway_iam_application.kubernetes.id
  rule {
    permission_set_names = ["SecretManagerReadOnly", "SecretManagerSecretAccess", "ContainerRegistryReadOnly"]
    project_ids          = [data.scaleway_account_project.emplois_cnav.id]
  }
}
