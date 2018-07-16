# terraform-digitalocean-strelaysrv-node
# ============================================================================

# Copyright (c) 2018 Verb Networks Pty Ltd <contact [at] verbnetworks.com>
#  - All rights reserved.
#
# Apache License v2.0
#  - http://www.apache.org/licenses/LICENSE-2.0

# establish the digitalocean provider
provider "digitalocean" {
  token = "${var.digitalocean_token}"
}

# user_data
# ============================================================================
data "template_file" "cloudinit-bootstrap-sh" {
  template = "${file("${path.module}/data/cloudinit-bootstrap.sh")}"
  vars {
    hostname = "${var.hostname}"
    loginuser = "${var.loginuser}"
    loginuser_sshkey = "${var.loginuser_sshkey}"
    strelaysrv_extaddress = "${var.strelaysrv_extaddress}"
    strelaysrv_globalrate = "${var.strelaysrv_globalrate}"
    strelaysrv_messagetimeout = "${var.strelaysrv_messagetimeout}"
    strelaysrv_networktimeout = "${var.strelaysrv_networktimeout}"
    strelaysrv_persessionrate = "${var.strelaysrv_persessionrate}"
    strelaysrv_pinginterval = "${var.strelaysrv_pinginterval}"
    strelaysrv_pools = "${var.strelaysrv_pools}"
    strelaysrv_protocol = "${var.strelaysrv_protocol}"
    strelaysrv_providedby = "${var.strelaysrv_providedby}"
    strelaysrv_statussrv = "${var.strelaysrv_statussrv}"
  }
}

data "template_cloudinit_config" "node-userdata" {
  # NB: a cloudinit issue prevents gzip/base64 from working at digitalocean, thus using the base64gzip technique
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"
    content      = "#!/bin/sh\necho -n '${base64gzip(data.template_file.cloudinit-bootstrap-sh.rendered)}' | base64 -d | gunzip | /bin/sh"
    filename     = "cloudinit-bootstrap.sh"
  }
}

# digitalocean_droplet
# ============================================================================
resource "digitalocean_droplet" "droplet_node" {
  name = "${var.hostname}"
  image = "${var.digitalocean_image}"
  region = "${var.digitalocean_region}"
  size = "${var.digitalocean_size}"
  backups = "${var.digitalocean_backups}"
  monitoring = "${var.digitalocean_monitoring}"
  ipv6 = "${var.digitalocean_ipv6}"
  private_networking = "${var.digitalocean_private_networking}"
  user_data = "${data.template_cloudinit_config.node-userdata.rendered}"
}

# NB: there is a very strong temptation to use floating_ip addresses here, as at writing (2017-12-30) the Terraform
# exposed Digital Ocean interface does not quite provide the right functionality to correctly implement static IPv4
# addresses without clobbering (hence loosing) them.  If you require static  IPv4 addresses you'll need to use the
# Digital Ocean webui manually or come up with a tool to interface with the Digital Ocean API to manage it.
