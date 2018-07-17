# Terraform + Digital Ocean + Syncthing Relay Server

Terraform module to create a Syncthing Relay Server on Digital Ocean.
 * [syncthing](https://syncthing.net)
 * [strelaysrv](https://docs.syncthing.net/users/strelaysrv.html)
 * [digital ocean](https://www.digitalocean.com/)


## Usage
Establishing a Syncthing Relay Server node on Digital Ocean can be made incredibly easy with this Terraform module as 
shown in the minimal example below:-

```hcl
variable "do_token" {}

module "terraform-digitalocean-strelaysrv-node" {
  source  = "verbnetworks/strelaysrv-node/digitalocean"

  # required variables
  digitalocean_token = "${var.do_token}"
  digitalocean_region = "sfo2"
  hostname = "node-8"

  # optional variables - but impossible to access console without setting
  loginuser = "myusername"
  loginuser_sshkey = "${trimspace(file("~/.ssh/authorized_keys"))}"
}
```

By default the `-pools` switch is enabled with `https://relays.syncthing.net/endpoint` hence causing the node to 
join the public pool.  In the same way as with the Syncthing Relay Server this is easily overridden by setting 
`strelaysrv_pools` to a blank value which will cause it to act privately.

## Droplet Startup
The system start and install cycles can take a few minutes to complete, once the `terraform apply` is complete you 
should be able to ssh into your Droplet after a few minutes - in this initial period the host is applying the Digital 
Ocean "vendor-data" cloudinit scripts to apply their patches and updates to the system first.

Once this is complete the "user-data" cloudinit scripts are then applied which causes the `loginuser` account to be 
created and for the syncthing-relayserver to be installed.

The whole process can take 5+ minutes to complete until the relay server is actually passing traffic, you may wish to
review the cloudinit logs to review the cloudinit startup progress:
```bash
sudo tail -f /var/log/cloud-init-output.log
```

## Monitoring
You can confirm the service is running via:-
```bash
sudo service strelaysrv status
```

After a few more minutes you should also be able to find your Droplet public IP address among the other relays here:  
[https://relays.syncthing.net/](https://relays.syncthing.net/)

You can watch the network traffic flows using `iftop` which gets installed for you:
```bash
sudo iftop
```


## Versions
 - v0.1x - initial release
 - v0.2x - variable name changes to bring them into line with other verbnetwork modules, easier to create a Droplet
   that works out of the box without digging around, considerable updates for Ubuntu 18.04 which are no longer 
   backward-compatible with earlier Ubuntu versions.


## History
This module was originally published via `github.com/ndejong/terraform-digitalocean-strelaysrv-node` and was 
subsequently moved which required it to be removed and re-added within the Terraform Module repository.


****

## Input Variables - Required

#### hostname
The hostname applied to this strelaysrv-node droplet.

#### digitalocean_region
The DigitalOcean region-slug to start this strelaysrv-node within (nyc1, sgp1, lon1, nyc3, ams3, fra1, tor1, sfo2, blr1)

#### digitalocean_token
Your DigitalOcean API token used to issue cURL API calls directly to DigitalOcean to create the required image


## Input Variables - Required, with defaults available

#### loginuser
The user login user to create with passwordless sudo access for this strelaysrv-node, if empty no account will be created. NB: the root account is always disabled."
 - default = ""

#### loginuser_sshkey
The sshkey to inject into the loginuser account - NB: password based ssh auth is always disabled."
 - default = ""

#### digitalocean_image
The digitalocean image to use as the base for this strelaysrv-node."
 - default = "ubuntu-18-04-x64"

#### digitalocean_size
The digitalocean droplet size to use for this strelaysrv-node."
 - default = "s-1vcpu-1gb"

#### digitalocean_backups
Enable/disable digitalocean-droplet backup functionality on this strelaysrv-node."
 - default = false

#### digitalocean_monitoring
Enable/disable digitalocean-droplet monitoring functionality on this strelaysrv-node."
 - default = true

#### digitalocean_ipv6
Enable/disable getting a public IPv6 on this digitalocean-droplet."
 - default = true

#### digitalocean_private_networking
Enable/disable digitalocean-droplet private-networking functionality on this strelaysrv-node."
 - default = false


## Input Variables - Syncthing Relay Server - Optional

### strelaysrv_extaddress
An optional address to advertising as being available on. Allows listening on an unprivileged port with port forwarding from e.g. 443, and be connected to on port 443.
 - default = ":443"

### strelaysrv_globalrate
Global rate limit, in bytes/s.
 - default = "0"

### strelaysrv_messagetimeout
Maximum amount of time we wait for relevant messages to arrive (default 1m0s).
 - default = "60s"

### strelaysrv_networktimeout
Timeout for network operations between the client and the relay. If no data is received between the client and the relay in this period of time, the connection is terminated. Furthermore, if no data is sent between either clients being relayed within this period of time, the session is also terminated. (default 2m0s)
 - default "120s"

### strelaysrv_persessionrate
Per session rate limit, in bytes/s.
 - default = "0"

### strelaysrv_pinginterval
How often pings are sent (default 1m0s).
 - default = "60s"

### strelaysrv_pools
Comma separated list of relay pool addresses to join (default http://relays.syncthing.net/endpoint). Blank to disable announcement to a pool, thereby remaining a private relay.
 - default = "https://relays.syncthing.net/endpoint"

### strelaysrv_protocol
Protocol used for listening. tcp for IPv4 and IPv6, tcp4 for IPv4, tcp6 for IPv6.
 - default = "tcp"

### strelaysrv_providedby
An description about who provides the relay.
 - default: ""

### strelaysrv_statussrv
Listen address for status service (default :22070). Status service is used by the relay pool server UI for displaying stats.
 - default = :22070


## Outputs

#### hostname
The hostname given to this strelaysrv-node.

#### loginuser
The user login user created with passwordless sudo access on this strelaysrv-node.

#### region
The digitalocean region this strelaysrv-node droplet is within.

#### ipv4_address
The public IPv4 address of this strelaysrv-node droplet.

#### ipv6_address
The public IPv6 address of this strelaysrv-node droplet.


## Authors
Module managed by [Verb Networks](https://github.com/verbnetworks)

## License
Apache 2 Licensed. See LICENSE for full details.
