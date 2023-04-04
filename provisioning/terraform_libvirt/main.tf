variable "cpu_per_node" {
  type    = number
  default = 2
}

variable "ram_per_node" {
  type    = number
  default = 8192
}

variable "arch_node_count" {
  type    = number
  default = 1
}
variable "ubuntu_node_count" {
  type    = number
  default = 1
}

variable "debian_node_count" {
  type    = number
  default = 1
}

variable "project_name" {
  type    = string
  default = "thelab"
}
# instance the provider
provider "libvirt" {
  uri = "qemu:///system"
}

# Base Cloud Image
resource "libvirt_volume" "arch_base_image" {
  name   = "arch_base_image"
  pool   = "default"
  source = "https://geo.mirror.pkgbuild.com/images/v20230315.134041/Arch-Linux-x86_64-cloudimg-20230315.134041.qcow2"
  format = "qcow2"
}
resource "libvirt_volume" "ubuntu_base_image" {
  name   = "ubuntu_base_image"
  pool   = "default"
  source = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
  format = "qcow2"
}
resource "libvirt_volume" "debian_base_image" {
  name   = "debian_base_image"
  pool   = "default"
  source = "https://cloud.debian.org/images/cloud/bullseye/20230124-1270/debian-11-genericcloud-amd64-20230124-1270.qcow2"
  format = "qcow2"
}

# Base images to use
resource "libvirt_volume" "arch_image" {
  count          = var.arch_node_count
  name           = "arch_${var.project_name}_${count.index}"
  base_volume_id = libvirt_volume.arch_base_image.id
  size           = "21474836480"
}
resource "libvirt_volume" "ubuntu_image" {
  count          = var.ubuntu_node_count
  name           = "ubuntu_${var.project_name}_${count.index}"
  base_volume_id = libvirt_volume.ubuntu_base_image.id
  size           = "21474836480"
}
resource "libvirt_volume" "debian_image" {
  count          = var.debian_node_count
  name           = "debian_${var.project_name}_${count.index}"
  base_volume_id = libvirt_volume.debian_base_image.id
  size           = "21474836480"
}

# Network with IPs within expected range
resource "libvirt_network" "internal_net" {
  name      = "${var.project_name}_net"
  mode      = "nat"
  autostart = true
  addresses = ["192.168.55.0/24"]
  dns {
    enabled = true
  }
  dhcp {
    enabled = false
  }
}

# Load cloud init config
data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
}
resource "libvirt_cloudinit_disk" "cloudinit" {
  name      = "${var.project_name}_cloudinit.iso"
  user_data = data.template_file.user_data.rendered
  pool      = "default"
}

# Create the machine
resource "libvirt_domain" "arch" {
  count  = var.arch_node_count
  name   = "${var.project_name}_arch_${count.index}"
  memory = var.ram_per_node
  vcpu   = var.cpu_per_node


  cloudinit = libvirt_cloudinit_disk.cloudinit.id

  network_interface {
    network_id     = libvirt_network.internal_net.id
    addresses      = ["192.168.55.1${count.index}"]
    wait_for_lease = true
  }
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }
  disk {
    volume_id = element(libvirt_volume.arch_image.*.id, count.index)
  }
  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}
resource "libvirt_domain" "debian" {
  count  = var.debian_node_count
  name   = "${var.project_name}_debian_${count.index}"
  memory = var.ram_per_node
  vcpu   = var.cpu_per_node


  cloudinit = libvirt_cloudinit_disk.cloudinit.id

  network_interface {
    network_id     = libvirt_network.internal_net.id
    addresses      = ["192.168.55.2${count.index}"]
    wait_for_lease = true
  }
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }
  disk {
    volume_id = element(libvirt_volume.debian_image.*.id, count.index)
  }
  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}
resource "libvirt_domain" "ubuntu" {
  count  = var.ubuntu_node_count
  name   = "${var.project_name}_ubuntu_${count.index}"
  memory = var.ram_per_node
  vcpu   = var.cpu_per_node


  cloudinit = libvirt_cloudinit_disk.cloudinit.id

  network_interface {
    network_id     = libvirt_network.internal_net.id
    addresses      = ["192.168.55.3${count.index}"]
    wait_for_lease = true
  }
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }
  disk {
    volume_id = element(libvirt_volume.ubuntu_image.*.id, count.index)
  }
  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

terraform {
  required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source = "multani/libvirt"
      version = "0.6.3-1+4"
    }
    null = {
      source = "hashicorp/null"
    }
    template = {
      source = "hashicorp/template"
    }
  }
}
