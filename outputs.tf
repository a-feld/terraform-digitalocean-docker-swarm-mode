output "manager_ips" {
  value       = module.managers.ipv4_addresses
  description = "The manager nodes public ipv4 adresses"
}

output "worker_ips" {
  value       = module.workers.ipv4_addresses
  description = "The worker nodes public ipv4 adresses"
}

output "manager_droplet_ids" {
  value       = module.managers.droplet_ids
  description = "The manager droplet ids"
}

output "worker_droplet_ids" {
  value       = module.workers.droplet_ids
  description = "The worker droplet ids"
}
