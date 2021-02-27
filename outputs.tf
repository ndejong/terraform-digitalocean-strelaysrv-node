# terraform-digitalocean-strelaysrv-node
# ============================================================================

# Copyright (c) 2018 Verb Networks Pty Ltd <contact [at] verbnetworks.com>
#  - All rights reserved.
#
# Apache License v2.0
#  - http://www.apache.org/licenses/LICENSE-2.0

# outputs
# ============================================================================

output "hostname" {
  description = "The hostname given to this strelaysrv-node."
  value = var.hostname
}

output "loginuser" {
  description = "The user login user created with passwordless sudo access on this strelaysrv-node."
  value = var.loginuser
}

output "region" {
  description = "The digitalocean region this strelaysrv-node droplet is within."
  value = module.droplet.region
}

output "ipv4_address" {
  description = "The public IPv4 address of this strelaysrv-node droplet."
  value = module.droplet.ipv4_address
}

output "ipv6_address" {
  description = "The public IPv6 address of this strelaysrv-node droplet."
  value = module.droplet.ipv6_address
}
