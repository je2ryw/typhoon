variable "cluster_name" {
  type        = "string"
  description = "Unique cluster name"
}

# kvm
variable "os_base_image" {
  type        = "string"
  description = "Container Linux base image for the domain instances (e.g. images/container-linux/stable/1688.5.3/coreos_production_qemu_image.img)"
}

variable "host_network_bridge_interface" {
  type        = "string"
  description = "The host bridge interface from the VM directly to the LAN."
}

variable "host_storage_pool" {
  type        = "string"
  description = "The pool where the resource will be created."
}

# machines
# Terraform's crude "type system" does not properly support lists of maps so we do this.

variable "controller_vcpu" {
  type        = "string"
  default     = "2"
  description = "Number of virtual CPUs"
}

variable "controller_memory_size" {
  type        = "string"
  default     = "2048"
  description = "Size of the memory in MB"
}

variable "controller_disk_size" {
  type        = "string"
  default     = "20"
  description = "Size of the disk in GB"
}

variable "controller_names" {
  type = "list"
}

variable "controller_macs" {
  type = "list"
}

variable "controller_domains" {
  type = "list"
}

variable "controller_clc_snippets" {
  type        = "list"
  description = "Controller Container Linux Config snippets"
  default     = []
}

variable "worker_vcpu" {
  type        = "string"
  default     = "2"
  description = "Number of virtual CPUs"
}

variable "worker_memory_size" {
  type        = "string"
  default     = "2048"
  description = "Size of the memory in MB"
}

# variable "worker_disk_size" {
#   type        = "string"
#   default     = "20"
#   description = "Size of the disk in GB"
# }

variable "worker_names" {
  type = "list"
}

variable "worker_macs" {
  type = "list"
}

variable "worker_domains" {
  type = "list"
}

variable "worker_clc_snippets" {
  type        = "list"
  description = "Worker Container Linux Config snippets"
  default     = []
}

# configuration

variable "k8s_domain_name" {
  description = "Controller DNS name which resolves to a controller instance. Workers and kubeconfig's will communicate with this endpoint (e.g. cluster.example.com)"
  type        = "string"
}

variable "ssh_authorized_key" {
  type        = "string"
  description = "SSH public key for user 'core'"
}

variable "asset_dir" {
  description = "Path to a directory where generated assets should be placed (contains secrets)"
  type        = "string"
}

variable "networking" {
  description = "Choice of networking provider (flannel or calico)"
  type        = "string"
  default     = "calico"
}

variable "network_mtu" {
  description = "CNI interface MTU (applies to calico only)"
  type        = "string"
  default     = "1480"
}

variable "pod_cidr" {
  description = "CIDR IPv4 range to assign Kubernetes pods"
  type        = "string"
  default     = "10.2.0.0/16"
}

variable "service_cidr" {
  description = <<EOD
CIDR IPv4 range to assign Kubernetes services.
The 1st IP will be reserved for kube_apiserver, the 10th IP will be reserved for kube-dns.
EOD

  type    = "string"
  default = "10.3.0.0/16"
}

# optional

variable "cluster_domain_suffix" {
  description = "Queries for domains with the suffix will be answered by kube-dns. Default is cluster.local (e.g. foo.default.svc.cluster.local) "
  type        = "string"
  default     = "cluster.local"
}

# unofficial, undocumented, unsupported, temporary

variable "controller_networkds" {
  type        = "list"
  description = "Controller Container Linux config networkd section"
  default     = []
}

variable "worker_networkds" {
  type        = "list"
  description = "Worker Container Linux config networkd section"
  default     = []
}
