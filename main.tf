
# user_data
# ============================================================================
data "template_file" "cloud-config" {
  template = "${file("${path.module}/etc/cloud-config.yaml")}"
  vars {
    user = "${var.user}"
    user_sshkey = "${var.user_sshkey}"
  }
}

data "template_file" "cloud-config-bootstrap-sh" {
  template = "${file("${path.module}/etc/cloud-config-bootstrap.sh")}"
  vars {
    hostname = "${var.hostname}"
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

  # NB: some kind of cloud-init issue prevents gzip/base64 from working at digitalocean
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.cloud-config.rendered}"
  }

  part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.cloud-config-bootstrap-sh.rendered}"
    filename     = "cloud-config-bootstrap.sh"
  }
}

# digitalocean_droplet
# ============================================================================
resource "digitalocean_droplet" "droplet_node" {
  image = "${var.image}"
  name = "${var.hostname}"
  region = "${var.region}"
  size = "${var.size}"
  backups = "${var.backups}"
  monitoring = "${var.monitoring}"
  ipv6 = "${var.ipv6}"
  private_networking = "${var.private_networking}"
  user_data = "${data.template_cloudinit_config.node-userdata.rendered}"
}

# NB: there is a very strong temptation to use floating_ip addresses here, as at
#     writing (2017-12-30) the Terraform exposed Digital Ocean interface does not
#     provide the right functionality to correctly implement static IPv4
#     addresses without clobbering (hence loosing) them.  If you require static
#     IPv4 addresses you'll need to use the Digital Ocean webui manually.
