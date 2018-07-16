# terraform-digitalocean-strelaysrv-node
# ============================================================================

# Copyright (c) 2018 Verb Networks Pty Ltd <contact [at] verbnetworks.com>
#  - All rights reserved.
#
# Apache License v2.0
#  - http://www.apache.org/licenses/LICENSE-2.0


# required variables
# ============================================================================

variable "hostname" {
  description = "The hostname applied to this strelaysrv-node droplet."
}

variable "digitalocean_region" {
  description = "The DigitalOcean region-slug to start this strelaysrv-node within (nyc1, sgp1, lon1, nyc3, ams3, fra1, tor1, sfo2, blr1)"
}

variable "digitalocean_token" {
  description = "Your DigitalOcean API token used to issue cURL API calls directly to DigitalOcean to create the required image"
}


# required variables - with defaults available
# ============================================================================

variable "loginuser" {
  description = "The user login user to create with passwordless sudo access for this strelaysrv-node, if empty no account will be created. NB: the root account is always disabled."
  default = ""
}

variable "loginuser_sshkey" {
  description = "The sshkey to inject into the loginuser account - NB: password based ssh auth is always disabled."
  default = ""
}

variable "digitalocean_image" {
  description = "The digitalocean image to use as the base for this strelaysrv-node."
  default = "ubuntu-18-04-x64"
}

variable "digitalocean_size" {
  description = "The digitalocean droplet size to use for this strelaysrv-node."
  default = "s-1vcpu-1gb"
  # s-1vcpu-1gb = $5 USD per/month and includes 1000GB pooled outbound data transfer allowance as at 2018-06
  # s-1vcpu-2gb = $10 USD per/moath and includes 2000GB pooled outbound data transfer allowance as at 2018-06
  # Reference: https://www.digitalocean.com/docs/release-notes/2018/droplet-bandwidth-billing/
}

variable "digitalocean_backups" {
  description = "Enable/disable digitalocean-droplet backup functionality on this strelaysrv-node."
  default = false
}

variable "digitalocean_monitoring" {
  description = "Enable/disable digitalocean-droplet monitoring functionality on this strelaysrv-node."
  default = true
}

variable "digitalocean_ipv6" {
  description = "Enable/disable getting a public IPv6 on this digitalocean-droplet."
  # NB: worth enabling since some transit routes are lower latency via IPv6 than IPv4, however not many IPv6 nodes out there...
  default = true
}

variable "digitalocean_private_networking" {
  description = "Enable/disable digitalocean-droplet private-networking functionality on this strelaysrv-node."
  default = false
}


# optional variables (all strelaysrv related)
# ============================================================================

# NB:-
# "strelaysrv_keys" - is hardcoded to "/etc/strelaysrv" to provide a predictable path
# "strelaysrv_listen" - is hardcoded to ":22067" to provide a predictable iptables nat forward for ${strelaysrv_extaddress}
# "*-nat" options - not implemented since they are not required in an envrionment where the node directly has a public address

variable "strelaysrv_extaddress" {
  description = "The address (and port) to advertise for this node.  NB: other clients are more likely to achieve a connection on TCP443 hence we perform some internal NAT magic to forward TCP443 to TCP22067."
  default = ":443"
}

variable "strelaysrv_globalrate" {
  description = "Global rate limit in bytes/s for this node."
  default = "0"
}

variable "strelaysrv_messagetimeout" {
  description = "Maximum amount of time to wait for relevant messages to arrive (default 60s)."
  default = "60s"
}

variable "strelaysrv_networktimeout" {
  description = "Timeout for network operations between the client and the relay. If no data is received between the client and the relay in this period of time, the connection is terminated. Furthermore, if no data is sent between either clients being relayed within this period of time, the session is also terminated. (default 120s)"
  default = "120s"
}

variable "strelaysrv_persessionrate" {
  description = "Per session rate limit, in bytes/s."
  default = "0"
}

variable "strelaysrv_pinginterval" {
  description = "How often pings are sent (default 60s)."
  default = "60s"
}

variable "strelaysrv_pools" {
  description = "Comma separated list of relay pool addresses to join (default http://relays.syncthing.net/endpoint).  Blank to disable announcement to a pool, thereby remaining a private only relay."
  default = "https://relays.syncthing.net/endpoint"
}

variable "strelaysrv_protocol" {
  description = "Protocol used for listening - use 'tcp' for both IPv4 and IPv6, 'tcp4' for IPv4 only, 'tcp6' for IPv6 only."
  default = "tcp"
}

variable "strelaysrv_providedby" {
  description = "An description about who provides the relay."
  default = ""
}

variable "strelaysrv_statussrv" {
  description = "Listen address for status service (default :22070). Status service is used by the relay pool server UI for displaying stats."
  default = ":22070"
}
