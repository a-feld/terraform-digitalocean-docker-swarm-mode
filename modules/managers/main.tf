data "ignition_file" "ca_cert" {
  filesystem = "root"
  path       = "/etc/docker/ca.pem"
  mode       = 420

  content {
    content = var.remote_api_ca
  }
}

data "ignition_file" "server_cert" {
  filesystem = "root"
  path       = "/etc/docker/server.pem"
  mode       = 420

  content {
    content = var.remote_api_certificate
  }
}

data "ignition_file" "server_key" {
  filesystem = "root"
  path       = "/etc/docker/server-key.pem"
  mode       = 420

  content {
    content = var.remote_api_key
  }
}

# docker dropin to enable TLS
data "ignition_systemd_unit" "docker_tls" {
  name = "docker.service"

  dropin {
    name = "10-docker-tls.conf"

    content = <<EOF
[Service]
Environment="DOCKER_OPTS=--tlsverify --tlscacert=/etc/docker/ca.pem --tlscert=/etc/docker/server.pem --tlskey=/etc/docker/server-key.pem"
EOF

  }
}

# add socket 2376 for docker TLS
data "ignition_systemd_unit" "docker_tls_socket" {
  name = "docker-tls-tcp.socket"

  content = <<EOF
[Unit]
Description=Docker Secured Socket for the API

[Socket]
ListenStream=2376
BindIPv6Only=both
Service=docker.service

[Install]
WantedBy=sockets.target
EOF

}

# RNGD service is required to pump entropy into the kernel. If this isn't
# done, dockerd will hang for 10-15 minutes on every boot
data "ignition_systemd_unit" "rngd" {
  name    = "rngd.service"
  enabled = true
}

locals {
  systemd = [
    data.ignition_systemd_unit.docker_tls.rendered,
    data.ignition_systemd_unit.docker_tls_socket.rendered,
    data.ignition_systemd_unit.rngd.rendered,
  ]
}

# Ignition config (with services on start)
data "ignition_config" "config" {
  systemd = concat(local.systemd, var.systemd_units)

  files = [
    data.ignition_file.ca_cert.rendered,
    data.ignition_file.server_cert.rendered,
    data.ignition_file.server_key.rendered,
  ]
}

resource "digitalocean_droplet" "manager" {
  count = var.total_instances
  image = var.image
  name = format(
    "%s-%02d.%s.%s",
    var.name,
    count.index + 1,
    var.region,
    var.domain,
  )
  size               = var.size
  private_networking = true
  region             = var.region
  ssh_keys           = var.ssh_keys
  user_data          = data.ignition_config.config.rendered
  tags               = var.tags

  connection {
    type    = "ssh"
    user    = "core"
    host    = self.ipv4_address
  }

  provisioner "remote-exec" {
    inline = [
      count.index == 0 ? "docker swarm init --advertise-addr ${self.ipv4_address_private} &>/dev/null" : "true",
    ]
  }

  provisioner "remote-exec" {
    when = destroy

    inline = [
      "timeout 25 docker swarm leave --force",
    ]

    on_failure = continue
  }
}

data "external" "swarm_tokens" {
  program    = ["bash", "${path.module}/scripts/get-swarm-join-tokens.sh"]
  depends_on = [digitalocean_droplet.manager]

  query = {
    host = element(digitalocean_droplet.manager.*.ipv4_address, 0)
    user = "core"
  }
}

resource "null_resource" "join" {
  count = var.total_instances - 1

  connection {
    host = element(digitalocean_droplet.manager.*.ipv4_address, count.index + 1)
    type = "ssh"
    user = "core"
  }

  provisioner "remote-exec" {
    inline = [
      "docker swarm join --token ${data.external.swarm_tokens.result["manager"]} ${digitalocean_droplet.manager[0].ipv4_address_private}",
    ]
  }
}
