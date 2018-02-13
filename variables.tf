
# required variables - no defaults
# ============================================================================

variable "hostname" {
  description = "The hostname applied to this strelaysrv-node droplet."
}

variable "region" {
  description = "The digitalocean region to start this strelaysrv-node within."
}

variable "user" {
  description = "The user initial login user to create with passwordless sudo access for this strelaysrv-node, if empty no account will be created. The root account is always disabled."
}

variable "user_sshkey" {
  description = "The sshkey to apply to the initial user account - password based auth is always disabled."
}

# required variables - with defined defaults
# ============================================================================

variable "image" {
  description = "The digitalocean image to use as the base for this strelaysrv-node."
  default = "ubuntu-16-04-x64"
}

variable "size" {
  description = "The digitalocean droplet size to use for this strelaysrv-node."
  default = "512mb"
  # 512mb = $5 with 1TB bandwidth per/month as at 2017-12
  # 1gb   = $10 with 2TB bandwidth per/month as at 2017-12
}

variable "backups" {
  description = "Enable/disable digitalocean-droplet backup functionality on this strelaysrv-node."
  default = false
}

variable "monitoring" {
  description = "Enable/disable digitalocean-droplet monitoring functionality on this strelaysrv-node."
  default = true
}

variable "ipv6" {
  description = "Enable/disable getting a public IPv6 on this digitalocean-droplet."
  default = true
}

variable "private_networking" {
  description = "Enable/disable digitalocean-droplet private-networking functionality on this strelaysrv-node."
  default = false
}

# strelaysrv variables - all optional
# ============================================================================
variable "strelaysrv_extaddress" {
  description = "An optional address to advertising as being available on. Allows listening on an unprivileged port with port forwarding from e.g. 443, and be connected to on port 443."
  default = ":443"
}

variable "strelaysrv_globalrate" {
  description = "Global rate limit, in bytes/s."
  default = "0"
}

# strelaysrv_keys is hardcoded to "/etc/strelaysrv" to provide a predictable path
# strelaysrv_listen is hardcoded to ":22067" to provide a predictable iptables nat forward for ${strelaysrv_extaddress}

variable "strelaysrv_messagetimeout" {
  description = "Maximum amount of time we wait for relevant messages to arrive (default 1m0s)."
  default = "60s"
}

# -nat options are not implemented as they do not make sense in a public cloud-hosted envrionment.

variable "strelaysrv_networktimeout" {
  description = "Timeout for network operations between the client and the relay. If no data is received between the client and the relay in this period of time, the connection is terminated. Furthermore, if no data is sent between either clients being relayed within this period of time, the session is also terminated. (default 2m0s)"
  default = "120s"
}

variable "strelaysrv_persessionrate" {
  description = "Per session rate limit, in bytes/s."
  default = "0"
}

variable "strelaysrv_pinginterval" {
  description = "How often pings are sent (default 1m0s)."
  default = "60s"
}

variable "strelaysrv_pools" {
  description = "Comma separated list of relay pool addresses to join (default http://relays.syncthing.net/endpoint). Blank to disable announcement to a pool, thereby remaining a private relay."
  default = "https://relays.syncthing.net/endpoint"
}

variable "strelaysrv_protocol" {
  description = "Protocol used for listening. tcp for IPv4 and IPv6, tcp4 for IPv4, tcp6 for IPv6."
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
