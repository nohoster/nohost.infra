## Define controllers volumes and domains

resource "libvirt_volume" "controller-volume" {
  count = var.control_number
  name           = "controller${terraform.workspace}-volume-${count.index}"
  base_volume_id = libvirt_volume.os_image.id
  pool   = libvirt_pool.pool.name
  size = 10000000000
}

resource "libvirt_domain" "controller-kvm" {
  count = var.control_number
  name   = "control${count.index}-${terraform.workspace}"
  memory = "3815"
  vcpu   = 2
  autostart =true

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  disk {
    volume_id = element(libvirt_volume.controller-volume[*].id, count.index)
  }

  network_interface {
    network_name   = "terraform${terraform.workspace}-net"
    hostname = "controller-${terraform.workspace}${count.index}"
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

  provisioner "local-exec" {
    command = <<EOT
    IP=${ self.network_interface[0].addresses[0] } \
    NODE_TYPE=${ self.name } \
    CLUSTER='PRODUCTION-${terraform.workspace}' \
    K3S_SECRET=${var.K3S_SECRET} \
    GITHUB_TOKEN=${ var.GITHUB_TOKEN } \
    VAULT_TOKEN=${ var.VAULT_TOKEN } \
    TAILSCALE_TOKEN=${ var.TAILSCALE_TOKEN } \
    bash bootstrap.sh"
    EOT
    }
}

##Define workers volumes and domains

resource "libvirt_volume" "worker-volume" {
  count = var.worker_number
  name           = "worker${terraform.workspace}-volume-${count.index}"
  base_volume_id = libvirt_volume.os_image.id
  pool   = libvirt_pool.pool.name
  size = 10000000000
}

resource "libvirt_domain" "worker-kvm" {
  count = var.worker_number
  name   = "worker${count.index}-${terraform.workspace}"
  memory = "3815"
  vcpu   = 2
  autostart =true

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  disk {
    volume_id = element(libvirt_volume.worker-volume[*].id, count.index)
  }

  network_interface {
    network_name   = "terraform${terraform.workspace}-net"
      hostname = "worker${terraform.workspace}-${count.index}"

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
  provisioner "local-exec" {
       command = <<EOT
       IP=${ self.network_interface[0].addresses[0] } \
       NODE_TYPE=${ self.name } \
       SERVER_IP=${ libvirt_domain.controller-kvm[0].network_interface[0].addresses[0] } \
       K3S_SECRET=${var.K3S_SECRET} \
       GITHUB_TOKEN=${ var.GITHUB_TOKEN } \
       VAULT_TOKEN=${ var.VAULT_TOKEN } \
       TAILSCALE_TOKEN=${ var.TAILSCALE_TOKEN } \
       CLUSTER='PRODUCTION-${terraform.workspace}' \
       bash bootstrap.sh
       EOT
    }
}
