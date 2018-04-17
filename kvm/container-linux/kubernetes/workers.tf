# Worker domain instances
resource "libvirt_volume" "workers" {
  count          = "${length(var.worker_names)}"
  name           = "${format("%s-worker-%s", var.cluster_name, element(var.worker_names, count.index))}"
  pool           = "${var.host_storage_pool}"
  base_volume_id = "${libvirt_volume.os_base_volume.id}"

  # size           = "${var.worker_disk_size * 1024 * 1024 * 1024}"
}

resource "libvirt_ignition" "workers" {
  count   = "${length(var.worker_names)}"
  name    = "${format("%s-worker-%s", var.cluster_name, element(var.worker_names, count.index))}"
  content = "${element(data.ct_config.worker_ign.*.rendered, count.index)}"
}

resource "libvirt_domain" "workers" {
  count  = "${length(var.worker_names)}"
  name   = "${format("%s-worker-%s", var.cluster_name, element(var.worker_names, count.index))}"
  vcpu   = "${var.worker_vcpu}"
  memory = "${var.worker_memory_size}"

  # storage
  disk {
    volume_id = "${element(libvirt_volume.workers.*.id, count.index)}"
  }

  # network
  network_interface {
    hostname = "${element(var.worker_domains, count.index)}"
    mac      = "${element(var.worker_macs, count.index)}"
    bridge   = "${var.host_network_bridge_interface}"
  }

  # console
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  coreos_ignition = "${element(libvirt_ignition.workers.*.id, count.index)}"
}

# Worker Container Linux Config
data "template_file" "worker_config" {
  count = "${length(var.worker_names)}"

  template = "${file("${path.module}/cl/worker.yaml.tmpl")}"

  vars = {
    domain_name           = "${element(var.worker_domains, count.index)}"
    k8s_dns_service_ip    = "${cidrhost(var.service_cidr, 10)}"
    cluster_domain_suffix = "${var.cluster_domain_suffix}"
    ssh_authorized_key    = "${var.ssh_authorized_key}"

    # Terraform evaluates both sides regardless and element cannot be used on 0 length lists
    networkd_content = "${length(var.worker_networkds) == 0 ? "" : element(concat(var.worker_networkds, list("")), count.index)}"
  }
}

data "ct_config" "worker_ign" {
  count        = "${length(var.worker_names)}"
  content      = "${element(data.template_file.worker_config.*.rendered, count.index)}"
  pretty_print = false

  snippets = ["${var.worker_clc_snippets}"]
}
