# Terraform + Digital Ocean + Syncthing Relay Server

Terraform module to create a Syncthing Relay Server, optionally with pre-existing key material.
 * [syncthing](https://syncthing.net)
 * [strelaysrv](https://docs.syncthing.net/users/strelaysrv.html)
 * [digital ocean](https://www.digitalocean.com/)

## Usage
Establishing a Syncthing Relay Server node on Digital Ocean can be made incredibly easy with 
this Terraform module as shown in the minimal example below:-

```hcl
module "node0-sfo2-digitalocean" {
  source = "../../modules/terraform-digitalocean-strelaysrv-node"
  size = "512mb"
  region = "sfo2"
  hostname = "node0-sfo2-digitalocean"
  user = "<username>"
  user_sshkey = "<ssh-public-key>"
}
```


## Authors
Module managed by [Nicholas de Jong](https://github.com/ndejong).

## License
Apache 2 Licensed. See LICENSE for full details.
