output "ipv4_addresses" {
  value       = ["${digitalocean_droplet.worker.*.ipv4_address}"]
  description = "The worker nodes public ipv4 adresses"
}

output "droplet_ids" {
  value       = ["${digitalocean_droplet.worker.*.id}"]
  description = "The droplet ids"
}
