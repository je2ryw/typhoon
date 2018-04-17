# Controller domain instances
resource "libvirt_volume" "controllers" {
  count          = "${length(var.controller_names)}"
  name           = "${format("%s-controller-%s", var.cluster_name, element(var.controller_names, count.index))}"
  pool           = "${var.host_storage_pool}"
  base_volume_id = "${libvirt_volume.os_base_volume.id}"

  #  size           = "${var.controller_disk_size * 1024 * 1024 * 1024}"
}

resource "libvirt_ignition" "controllers" {
  count   = "${length(var.controller_names)}"
  name    = "${format("%s-controller-%s", var.cluster_name, element(var.controller_names, count.index))}"
  content = "${element(data.ct_config.controller_ign.*.rendered, count.index)}"
}

resource "libvirt_domain" "controllers" {
  count  = "${length(var.controller_names)}"
  name   = "${format("%s-controller-%s", var.cluster_name, element(var.controller_names, count.index))}"
  vcpu   = "${var.controller_vcpu}"
  memory = "${var.controller_memory_size}"

  # storage
  disk {
    volume_id = "${element(libvirt_volume.controllers.*.id, count.index)}"
  }

  # network
  network_interface {
    hostname = "${element(var.controller_domains, count.index)}"
    mac      = "${element(var.controller_macs, count.index)}"
    bridge   = "${var.host_network_bridge_interface}"
  }

  # console
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  coreos_ignition = "${element(libvirt_ignition.controllers.*.id, count.index)}"
}

# Controller Container Linux Config
data "template_file" "controller_config" {
  count = "${length(var.controller_names)}"

  template = "${file("${path.module}/cl/controller.yaml.tmpl")}"

  vars = {
    domain_name           = "${element(var.controller_domains, count.index)}"
    etcd_name             = "${element(var.controller_names, count.index)}"
    etcd_initial_cluster  = "${join(",", formatlist("%s=https://%s:2380", var.controller_names, var.controller_domains))}"
    k8s_dns_service_ip    = "${cidrhost(var.service_cidr, 10)}"
    cluster_domain_suffix = "${var.cluster_domain_suffix}"
    ssh_authorized_key    = "${var.ssh_authorized_key}"

    # Terraform evaluates both sides regardless and element cannot be used on 0 length lists
    networkd_content = "${length(var.controller_networkds) == 0 ? "" : element(concat(var.controller_networkds, list("")), count.index)}"
  }
}

data "ct_config" "controller_ign" {
  count        = "${length(var.controller_names)}"
  content      = "${element(data.template_file.controller_config.*.rendered, count.index)}"
  pretty_print = false

  snippets = ["${var.controller_clc_snippets}"]
}
