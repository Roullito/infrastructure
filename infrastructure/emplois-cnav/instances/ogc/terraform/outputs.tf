output "ogc_public_ip" {
  description = "Public IP address of the OGC instance"
  value       = scaleway_instance_ip.ogc_ip.address
}
