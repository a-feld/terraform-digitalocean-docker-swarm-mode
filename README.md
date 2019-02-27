# Terraform DigitalOcean Docker Swarm mode

Terraform module to provision a Docker Swarm mode cluster in a single availability zone on DigitalOcean.

- [Requirements](#requirements)
- [Usage](#usage)
- [Examples](#examples)
- [Swarm set-up](#swarm-set-up)

## Requirements

- Terraform >= 0.11.7
- Digitalocean account / API token with write access
- SSH Keys added to your DigitalOcean account
- [jq](https://github.com/stedolan/jq)

## Usage

```hcl
module "swarm_mode_cluster" {
  source           = "github.com/a-feld/terraform-digitalocean-docker-swarm-mode"
  domain           = "do.example.com"
  total_managers   = 3
  total_workers    = 2
  ssh_keys         = [1234, 1235, ...]

  remote_api_ca          = "${var.ca_cert}"
  remote_api_certificate = "${var.server_cert}"
  remote_api_key         = "${var.server_key}"

  manager_size = "s-2vcpu-4gb"
  worker_size  = "s-1vcpu-1gb"
  manager_tags = ["${digitalocean_tag.cluster.id}", "${digitalocean_tag.manager.id}"]
  worker_tags  = ["${digitalocean_tag.cluster.id}", "${digitalocean_tag.worker.id}"]
  providers = {}
}
```

### SSH Key

Terraform uses an SSH key to connect to the created droplets in order to issue `docker swarm join` commands. By default this uses `~/.ssh/id_rsa`.You also need to ensure the public key is added to your DigitalOcean account and it's listed in the `ssh_keys` list.

### Exposing the Docker API

You can expose the Docker API to interact with the cluster remotely. This is done by providing a certificate and private key. Creating these keys can be done using the [tls provider](https://www.terraform.io/docs/providers/tls/index.html). Instructions on creating the required certificates are available [here](https://coreos.com/os/docs/latest/generate-self-signed-certificates.html).

> Note that for this to work, you need to open the Docker remote API port in both iptables (not necessary with default images) and the DigitalOcean cloud firewall.

### Supported OS

This module will only work on CoreOS distributions provided by DigitalOcean.

### Ports & Firewall

Ensure the following ports are open on the local firewall;

Port       | Description                       | Note
---------- | --------------------------------- | -------
`2377/TCP` | cluster management communications | Cluster
`7946/TCP` | Container network discovery       | Cluster
`7946/UDP` | Container network discovery       | Cluster
`4789/UDP` | Container overlay network         | Cluster
`2376/TCP` | Docker Remote API | Optionally, when exposing the Docker Remote API

For example, when using the Docker images provided by DigitalOcean, run the following command:

```bash
ufw allow 2377
ufw allow 7946
ufw allow 7946/udp
ufw allow 4789/udp
```

#### Cloud Firewall

Also set up firewall rules on DigitalOcean for the cluster, to ensure only cluster members can access the internal Swarm ports. You can use the [digitalocean-docker-swarm-firewall](https://github.com/thojkooi/terraform-digitalocean-docker-swarm-firewall) module for this. Look in the [firewall examples directory](https://github.com/a-feld/terraform-digitalocean-docker-swarm-mode/tree/master/examples/firewall) for inspiration on how to do this.

## Examples

For examples, see the [examples directory](https://github.com/a-feld/terraform-digitalocean-docker-swarm-mode/tree/master/examples).

## Swarm mode set-up

### Manager nodes

First a single Swarm mode manager is provisioned. This is the initial leader node. If you have additional manager nodes, these will be provisioned after this step. Once the manager nodes have been provisioned, Terraform will initialize the Swarm on the first manager node and retrieve the join tokens. It will then have all the managers join the cluster.

If the cluster is already up and running, Terraform will check with the first leader node to refresh the join tokens. It will join any additional manager nodes that are provisioned to the Swarm mode cluster.

#### Access the API

To expose the Swarm mode API in HA, create a load balancer and forward tcp traffic to port `2376`. Ensure you expose the docker remote API using certificates when doing this. Alternatively you can do DNS round-robin load balancing.

When you do not wish to expose your Docker API, you can use SSH to connect to one of the manager nodes and access the Docker API through this.

### Worker nodes

Worker nodes should be used to run the Docker Swarm mode Services. By default, 2 worker nodes are provisioned. Set the number of desired worker nodes using the following variable: `total_workers`.

## License

This repository is forked from [thojkooi/terraform-digitalocean-docker-swarm-mode](https://github.com/thojkooi/terraform-digitalocean-docker-swarm-mode)

[MIT © Thomas Kooi](LICENSE)
