variable "connection_timeout" {
  description = "Timeout for connection to servers"
  default     = "2m"
}

variable "domain" {
  description = "Domain name used in droplet hostnames, e.g example.com"
}

variable "ssh_keys" {
  type        = "list"
  description = "A list of SSH IDs or fingerprints to enable in the format [12345, 123456] that are added to the provisioned nodes"
}

variable "provision_ssh_key" {
  default     = "~/.ssh/id_rsa"
  description = "File path to SSH private key used to access the provisioned nodes. Ensure this key is listed in the manager and work ssh keys list"
}

variable "provision_user" {
  default     = "root"
  description = "User used to log in to the droplets via ssh for issueing Docker commands"
}

variable "region" {
  description = "Datacenter region in which the cluster will be created"
  default     = "nyc3"
}

variable "total_managers" {
  description = "Total number of managers in cluster"
  default     = 1
}

variable "total_workers" {
  description = "Total number of workers in cluster"
  default     = 1
}

variable "manager_image" {
  description = "Image for the manager nodes"
  default     = "coreos-alpha"
}

variable "worker_image" {
  description = "Droplet image for the worker nodes"
  default     = "coreos-alpha"
}

variable "manager_size" {
  description = "Droplet size of worker nodes"
  default     = "s-1vcpu-1gb"
}

variable "worker_size" {
  description = "Droplet size of worker nodes"
  default     = "s-1vcpu-1gb"
}

variable "manager_name" {
  description = "Prefix for name of manager nodes"
  default     = "manager"
}

variable "worker_name" {
  description = "Prefix for name of worker nodes"
  default     = "worker"
}

variable "manager_tags" {
  description = "List of DigitalOcean tag ids"
  default     = []
  type        = "list"
}

variable "manager_systemd_units" {
  description = "List of systemd units to install on manager machines"
  default     = []
  type        = "list"
}

variable "worker_tags" {
  description = "List of DigitalOcean tag ids"
  default     = []
  type        = "list"
}

variable "worker_systemd_units" {
  description = "List of systemd units to install on worker machines"
  default     = []
  type        = "list"
}

variable "remote_api_ca" {
  description = "CA file contents for the docker remote API"
}

variable "remote_api_certificate" {
  description = "Certificate file contents for the docker remote API"
}

variable "remote_api_key" {
  description = "Private key file contents for the docker remote API"
}
