# Terraform + Digital Ocean + Syncthing Relay Server

Terraform module to create a Syncthing Relay Server on Digital Ocean.
 * [syncthing](https://syncthing.net)
 * [strelaysrv](https://docs.syncthing.net/users/strelaysrv.html)
 * [digital ocean](https://www.digitalocean.com/)

## Usage
Establishing a Syncthing Relay Server node on Digital Ocean can be made incredibly easy with this Terraform module as 
shown in the minimal example below:-

```hcl
module "relay01-digitalocean-sf03" {
  source  = "verbnetworks/strelaysrv-node/digitalocean"

  # required variables
  # ===
  hostname = "relay01"
  digitalocean_region = "sfo3"

  # optional, however impossible to access without setting the `loginuser` and `loginuser_sshkey` variables 
  # ===
  loginuser = "myusername"
  loginuser_sshkey = trimspace(file("~/.ssh/authorized_keys"))
}
```

By default the `-pools` switch is enabled with `https://relays.syncthing.net/endpoint` which causes the node to 
join the public pool.  In the same way as with the Syncthing Relay Server this is easily overridden by setting 
`strelaysrv_pools` to a blank value which will cause the relay to act privately.

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
sudo systemctl status syncthing-relaysrv
```

After a few more minutes you should also be able to find your Droplet public IP address among the other relays here:  
[https://relays.syncthing.net/](https://relays.syncthing.net/)

You can watch the network traffic flows using `iftop` which is installed for you:
```bash
sudo iftop
```

## Versions
 - v0.1x - initial release
 - v0.2x - variable name changes to bring them into line with other verbnetwork modules, easier to create a Droplet
   that works out of the box without digging around, considerable updates for Ubuntu 18.04 which are no longer 
   backward-compatible with earlier Ubuntu versions.
 - v0.3x - rebuild release for Terraform 0.13 and up, and now imports  verbnetworks/terraform-digitalocean-droplet 

## History
This module was originally published via `github.com/ndejong/terraform-digitalocean-strelaysrv-node` and was 
subsequently moved which required it to be removed and re-added within the Terraform Module repository.

## Authors
Module managed by [Verb Networks](https://github.com/verbnetworks)

## License
Apache 2 Licensed. See LICENSE for full details.
