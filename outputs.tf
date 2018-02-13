
# outputs
# ============================================================================

output "hostname" {
  description = "The hostname given to this strelaysrv-node."
  value = "${var.hostname}"
}

output "region" {
  description = "The digitalocean region this strelaysrv-node droplet is within."
  value = "${var.region}"
}

output "user" {
  description = "The user login user created with passwordless sudo access on this strelaysrv-node."
  value = "${var.user}"
}

output "ipv4_address" {
  description = "The public IPv4 address of this strelaysrv-node droplet."
  value = "${digitalocean_droplet.droplet_node.ipv4_address}"
}

output "ipv6_address" {
  description = "The public IPv6 address of this strelaysrv-node droplet."
  value = "${digitalocean_droplet.droplet_node.ipv6_address}"
}
