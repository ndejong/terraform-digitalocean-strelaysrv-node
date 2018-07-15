# Terraform + Digital Ocean + Syncthing Relay Server

Terraform module to create a Syncthing Relay Server on Digital Ocean.
 * [syncthing](https://syncthing.net)
 * [strelaysrv](https://docs.syncthing.net/users/strelaysrv.html)
 * [digital ocean](https://www.digitalocean.com/)


## Usage
Establishing a Syncthing Relay Server node on Digital Ocean can be made incredibly easy with 
this Terraform module as shown in the minimal example below:-

```hcl
module "strelaysrv-node" {
  source  = "verbnetworks/strelaysrv-node/digitalocean"
  region = "sfo2"
  hostname = "node0-sfo2-do"
  user = "<username>"
  user_sshkey = "<ssh-public-key>"
}
```

By default the -pools switch is enabled with `https://relays.syncthing.net/endpoint` hence causing the 
node to automatically join the public pool - in the same way as with the Syncthing Relay Server this
is easily overridden by setting `strelaysrv_pools` to a blank value.

NB: the required install cycles can take a few minutes to complete, do a `tail -f /var/log/cloud-init-output.log` 
to watch the progress - you will recognise when everything is complete by the ascii-art hostname when ssh'ing 
into the host.


## Input Variables - Required

### hostname
The hostname applied to this strelaysrv-node droplet.

### region
The digitalocean region to start this strelaysrv-node within.

### user
The user initial login user to create with passwordless sudo access for this strelaysrv-node, if empty no account will be 
created. The root account is always disabled.

### user_sshkey
The sshkey to apply to the initial user account - password based auth is always disabled.

## Input Variables - Optional

### image
The digitalocean image to use as the base for this strelaysrv-node.
 - Default: "ubuntu-17-10-x64"

### size
The digitalocean droplet size to use for this strelaysrv-node.
 - Default: "1gb"

### backups
Enable/disable droplet backup functionality on this strelaysrv-node.
 - Default: false

### monitoring
Enable/disable droplet monitoring functionality on this strelaysrv-node.
 - Default: true

### ipv6
Enable/disable getting a public IPv6 on this digitalocean-droplet.
 - Default: true

### private_networking
Enable/disable digitalocean private-networking functionality on this strelaysrv-node.
 - Default: true

## Input Variables - Syncthing Relay Server - Optional

### strelaysrv_extaddress
An optional address to advertising as being available on. Allows listening on an unprivileged port with port forwarding from e.g. 443, and be connected to on port 443.
 - Default = :443

### strelaysrv_globalrate
Global rate limit, in bytes/s.
 - Default: 0

### strelaysrv_messagetimeout
Maximum amount of time we wait for relevant messages to arrive (default 1m0s).
 - Default: 60s

### strelaysrv_networktimeout
Timeout for network operations between the client and the relay. If no data is received between the client and the relay in this period of time, the connection is terminated. Furthermore, if no data is sent between either clients being relayed within this period of time, the session is also terminated. (default 2m0s)
 - Default: 120s

### strelaysrv_persessionrate
Per session rate limit, in bytes/s.
 - Default: 0

### strelaysrv_pinginterval
How often pings are sent (default 1m0s).
 - Default: 60s

### strelaysrv_pools
Comma separated list of relay pool addresses to join (default http://relays.syncthing.net/endpoint). Blank to disable announcement to a pool, thereby remaining a private relay.
 - Default: https://relays.syncthing.net/endpoint

### strelaysrv_protocol
Protocol used for listening. tcp for IPv4 and IPv6, tcp4 for IPv4, tcp6 for IPv6.
 - Default: tcp

### strelaysrv_providedby
An description about who provides the relay.
 - Default: <empty>

### strelaysrv_statussrv
Listen address for status service (default :22070). Status service is used by the relay pool server UI for displaying stats.
 - Default = :22070


## Outputs

### hostname
The hostname given to this strelaysrv-node.

### region
The digitalocean region this strelaysrv-node is within

### user
The user initial login user created with passwordless sudo access on this strelaysrv-node if set.

### ipv4_address
The public digitalocean-droplet IPv4 address of this strelaysrv-node.

### ipv6_address
The public digitalocean-droplet IPv6 address of this strelaysrv-node.


## Authors
Module managed by [Verb Networks](https://github.com/verbnetworks)

## License
Apache 2 Licensed. See LICENSE for full details.
