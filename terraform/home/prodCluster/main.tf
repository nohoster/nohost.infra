## Define controllers volumes and domains

resource "libvirt_volume" "controller-volume" {
  count          = var.control_number
  name           = "controller${terraform.workspace}-volume-${count.index}"
  base_volume_id = libvirt_volume.os_image.id
  pool           = libvirt_pool.pool.name
  size           = 10000000000
}

resource "libvirt_domain" "controller-kvm" {
  count     = var.control_number
  name      = "production-${terraform.workspace}-control${count.index}"
  memory    = "3815"
  vcpu      = 2
  autostart = true

  cloudinit = element(libvirt_cloudinit_disk.controller-init[*].id, count.index)

  disk {
    volume_id = element(libvirt_volume.controller-volume[*].id, count.index)
  }

  network_interface {
    network_name   = "terraform${terraform.workspace}-net"
    hostname       = "production-${terraform.workspace}-control${count.index}"
    wait_for_lease = true
  }

  provisioner "local-exec" {
    command = <<EOT
    IP=${self.network_interface[0].hostname} \
    NODE_TYPE=control${count.index} \
    CLUSTER='production-${terraform.workspace}' \
    K3S_SECRET=${var.K3S_SECRET} \
    GITHUB_TOKEN=${var.GITHUB_TOKEN} \
    VAULT_TOKEN=${var.VAULT_TOKEN} \
    bash bootstrap.sh
    EOT
  }
}

##Define workers volumes and domains

resource "libvirt_volume" "worker-volume" {
  count          = var.worker_number
  name           = "worker${terraform.workspace}-volume-${count.index}"
  base_volume_id = libvirt_volume.os_image.id
  pool           = libvirt_pool.pool.name
  size           = 10000000000
}

resource "libvirt_domain" "worker-kvm" {
  count     = var.worker_number
  name      = "production-${terraform.workspace}-worker${count.index}"
  memory    = "3815"
  vcpu      = 2
  autostart = true

  cloudinit = element(libvirt_cloudinit_disk.worker-init[*].id, count.index)

  disk {
    volume_id = element(libvirt_volume.worker-volume[*].id, count.index)
  }

  network_interface {
    network_name = "terraform${terraform.workspace}-net"
    hostname     = "production-${terraform.workspace}-worker${count.index}"
    wait_for_lease = true
  }
  provisioner "local-exec" {
    command = <<EOT
       IP=${self.network_interface[0].hostname} \
       NODE_TYPE=worker${count.index} \
       SERVER_IP=${libvirt_domain.controller-kvm[0].network_interface[0].addresses[0]} \
       K3S_SECRET=${var.K3S_SECRET} \
       GITHUB_TOKEN=${var.GITHUB_TOKEN} \
       VAULT_TOKEN=${var.VAULT_TOKEN} \
       CLUSTER='production-${terraform.workspace}' \
       bash bootstrap.sh
       EOT
  }
}
