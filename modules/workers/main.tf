# RNGD service is required to pump entropy into the kernel. If this isn't
# done, dockerd will hang for 10-15 minutes on every boot
data "ignition_systemd_unit" "rngd" {
  name    = "rngd.service"
  enabled = true
}

# Ignition config (with services on start)
data "ignition_config" "config" {
  systemd = [
    "${data.ignition_systemd_unit.rngd.id}",
  ]
}

resource "digitalocean_droplet" "worker" {
  count              = "${var.total_instances}"
  image              = "${var.image}"
  name               = "${format("%s-%02d.%s.%s", var.name, count.index + 1, var.region, var.domain)}"
  size               = "${var.size}"
  private_networking = true
  region             = "${var.region}"
  ssh_keys           = "${var.ssh_keys}"
  user_data          = "${data.ignition_config.config.rendered}"
  tags               = ["${var.tags}"]

  connection {
    type    = "ssh"
    user    = "core"
    timeout = "${var.connection_timeout}"
  }

  provisioner "remote-exec" {
    inline = [
      "docker swarm join --token ${var.join_token} ${var.manager_private_ip}",
    ]
  }

  provisioner "remote-exec" {
    when = "destroy"

    inline = [
      "timeout 25 docker swarm leave --force",
    ]

    on_failure = "continue"
  }
}
