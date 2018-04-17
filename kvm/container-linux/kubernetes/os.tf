resource "libvirt_volume" "os_base_volume" {
  name   = "${var.cluster_name}-os-base-volume"
  pool   = "${var.host_storage_pool}"
  source = "${var.os_base_image}"
}
