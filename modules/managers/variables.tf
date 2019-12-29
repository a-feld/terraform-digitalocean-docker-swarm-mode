variable "domain" {
  description = "Domain name used in droplet hostnames, e.g example.com"
}

variable "ssh_keys" {
  type        = list
  description = "A list of SSH IDs or fingerprints to enable in the format [12345, 123456] that are added to manager nodes"
}

variable "region" {
  description = "Datacenter region in which the cluster will be created"
  default     = "nyc3"
}

variable "total_instances" {
  description = "Total number of managers in cluster"
  default     = 1
}

variable "image" {
  description = "Droplet image used for the manager nodes"
  default     = "coreos-alpha"
}

variable "size" {
  description = "Droplet size of manager nodes"
  default     = "s-1vcpu-1gb"
}

variable "name" {
  description = "Prefix for name of manager nodes"
  default     = "manager"
}

variable "tags" {
  description = "List of DigitalOcean tag ids"
  default     = []
  type        = list
}

variable "remote_api_ca" {
  description = "CA file path for the docker remote API"
}

variable "remote_api_certificate" {
  description = "Certificate file path for the docker remote API"
}

variable "remote_api_key" {
  description = "Private key file path for the docker remote API"
}

variable "systemd_units" {
  description = "List of systemd units to install on machines"
  default     = []
  type        = list
}
