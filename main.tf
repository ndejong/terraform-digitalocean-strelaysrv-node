# terraform-digitalocean-strelaysrv-node
# ============================================================================

# Copyright (c) 2018 Verb Networks Pty Ltd <contact [at] verbnetworks.com>
#  - All rights reserved.
#
# Apache License v2.0
#  - http://www.apache.org/licenses/LICENSE-2.0

# strelaysrv-bootstrap
# ============================================================================
data "template_file" "strelaysrv-bootstrap-sh" {
  template = file("${path.module}/data/strelaysrv-bootstrap.sh")
  vars = {
    hostname = var.hostname
    strelaysrv_extaddress = var.strelaysrv_extaddress
    strelaysrv_globalrate = var.strelaysrv_globalrate
    strelaysrv_messagetimeout = var.strelaysrv_messagetimeout
    strelaysrv_networktimeout = var.strelaysrv_networktimeout
    strelaysrv_persessionrate = var.strelaysrv_persessionrate
    strelaysrv_pinginterval = var.strelaysrv_pinginterval
    strelaysrv_pools = var.strelaysrv_pools
    strelaysrv_protocol = var.strelaysrv_protocol
    strelaysrv_providedby = substr(var.strelaysrv_providedby, 0, 30)
    strelaysrv_statussrv = var.strelaysrv_statussrv
  }
}

module "droplet" {
  #source  = "verbnetworks/droplet/digitalocean"
  source  = "../terraform-digitalocean-droplet"
  hostname = var.hostname
  digitalocean_region = var.digitalocean_region
  digitalocean_backups = var.digitalocean_backups
  digitalocean_image = var.digitalocean_image
  digitalocean_ipv6 = var.digitalocean_ipv6
  digitalocean_monitoring = var.digitalocean_monitoring
  digitalocean_private_networking = false
  digitalocean_resize_disk = false
  digitalocean_size = var.digitalocean_size
  digitalocean_ssh_keys = []
  digitalocean_tags = var.digitalocean_tags
  initial_user = var.loginuser
  initial_user_sshkeys = [ var.loginuser_sshkey ]
  user_data = "#!/bin/sh\necho -n '${base64gzip(data.template_file.strelaysrv-bootstrap-sh.rendered)}' | base64 -d | gunzip | /bin/sh"
}
