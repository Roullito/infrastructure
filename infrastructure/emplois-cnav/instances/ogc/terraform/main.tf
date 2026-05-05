terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = ">= 2.60.0"
    }
  }
  required_version = ">= 1.10"
}

resource "scaleway_instance_ip" "ogc_ip" {}

resource "scaleway_instance_server" "ogc_instance" {
  name  = "ogc"
  type  = "POP2-2C-8G-WIN"
  image = "windows_server_2025"
  ip_id = scaleway_instance_ip.ogc_ip.id

  admin_password_encryption_ssh_key_id = data.scaleway_iam_ssh_key.leo_rsa.id

  root_volume {
    name                  = "ogc-root-volume"
    size_in_gb            = 25
    delete_on_termination = false
  }
}

resource "scaleway_block_snapshot" "ogc_installed_snapshot" {
  name      = "ogc-installed-snapshot"
  volume_id = scaleway_instance_server.ogc_instance.root_volume[0].volume_id
}
