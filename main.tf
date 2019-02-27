module "managers" {
  source = "./modules/managers"

  image  = "${var.manager_image}"
  size   = "${var.manager_size}"
  name   = "${var.manager_name}"
  region = "${var.region}"
  domain = "${var.domain}"

  total_instances = "${var.total_managers}"
  tags            = "${var.manager_tags}"

  remote_api_ca          = "${var.remote_api_ca}"
  remote_api_key         = "${var.remote_api_key}"
  remote_api_certificate = "${var.remote_api_certificate}"

  ssh_keys           = "${var.ssh_keys}"
  connection_timeout = "${var.connection_timeout}"
}

module "workers" {
  source = "./modules/workers"

  image  = "${var.worker_image}"
  size   = "${var.worker_size}"
  name   = "${var.worker_name}"
  region = "${var.region}"
  domain = "${var.domain}"

  total_instances = "${var.total_workers}"
  tags            = "${var.worker_tags}"

  manager_ip = "${element(module.managers.ipv4_addresses_private, 0)}"
  join_token = "${module.managers.worker_token}"

  ssh_keys           = "${var.ssh_keys}"
  connection_timeout = "${var.connection_timeout}"
}
