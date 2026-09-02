## Define controllers volumes and domains

resource "libvirt_volume" "controller-volume" {
  count    = var.control_number
  name     = "controller${terraform.workspace}-volume-${count.index}"
  pool     = libvirt_pool.pool.name
  capacity = 20000000000
  backing_store = {
    path = libvirt_volume.os_image.path
    format = {
      type = "qcow2"
    }
  }
  target = {
    format = {
      type = "qcow2"
    }
  }
}

resource "libvirt_domain" "controller-kvm" {
  count       = var.control_number
  name        = "production-${terraform.workspace}-control${count.index}"
  type        = "kvm"
  memory      = 4096
  memory_unit = "MiB"
  vcpu        = 3
  autostart   = true
  running     = true

  os = {
    type         = "hvm"
    type_arch    = "x86_64"
    type_machine = "q35"
    boot_devices = [
      { dev = "hd" },
    ]
  }

  devices = {
    disks = [
      {
        source = {
          file = { file = libvirt_volume.controller-volume[count.index].path }
        }
        target = {
          dev = "vda"
          bus = "virtio"
        }
        driver = {
          name = "qemu"
          type = "qcow2"
        }
      },
      {
        source = {
          file = { file = libvirt_volume.controller-cloudinit[count.index].path }
        }
        target = {
          dev = "vdb"
          bus = "virtio"
        }
        driver = {
          name = "qemu"
          type = "raw"
        }
      }
    ]
    interfaces = [
      {
        source = {
          network = { network = libvirt_network.terraform-net.name }
        }
        model = {
          type = "virtio"
        }
        wait_for_ip = {
          source  = "lease"
          network = "192.168.0.0/16"
          timeout = 600
        }
      }
    ]
    graphics = [
      {
        vnc = {
          autoport = true
          listeners = [
            {
              address = { address = "127.0.0.1" }
            }
          ]
        }
      }
    ]
  }
}

data "libvirt_domain_interface_addresses" "controller" {
  count      = var.control_number
  domain     = libvirt_domain.controller-kvm[count.index].name
  source     = "any"
  depends_on = [libvirt_domain.controller-kvm]
}

resource "terraform_data" "controller-bootstrap" {
  count            = var.control_number
  triggers_replace = [libvirt_domain.controller-kvm[count.index].uuid]

  provisioner "local-exec" {
    command = <<-EOT
      IP=${data.libvirt_domain_interface_addresses.controller[count.index].interfaces[0].addrs[0].addr} \
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
  count    = var.worker_number
  name     = "worker${terraform.workspace}-volume-${count.index}"
  pool     = libvirt_pool.pool.name
  capacity = 20000000000
  backing_store = {
    path = libvirt_volume.os_image.path
    format = {
      type = "qcow2"
    }
  }
  target = {
    format = {
      type = "qcow2"
    }
  }
}

resource "libvirt_domain" "worker-kvm" {
  count       = var.worker_number
  name        = "production-${terraform.workspace}-worker${count.index}"
  type        = "kvm"
  memory      = 4096
  memory_unit = "MiB"
  vcpu        = 3
  autostart   = true
  running     = true

  os = {
    type         = "hvm"
    type_arch    = "x86_64"
    type_machine = "q35"
    boot_devices = [
      { dev = "hd" },
    ]
  }

  devices = {
    disks = [
      {
        source = {
          file = { file = libvirt_volume.worker-volume[count.index].path }
        }
        target = {
          dev = "vda"
          bus = "virtio"
        }
        driver = {
          name = "qemu"
          type = "qcow2"
        }
      },
      {
        source = {
          file = { file = libvirt_volume.worker-cloudinit[count.index].path }
        }
        target = {
          dev = "vdb"
          bus = "virtio"
        }
        driver = {
          name = "qemu"
          type = "raw"
        }
      }
    ]
    interfaces = [
      {
        source = {
          network = { network = libvirt_network.terraform-net.name }
        }
        model = {
          type = "virtio"
        }
        wait_for_ip = {
          source  = "lease"
          network = "192.168.0.0/16"
          timeout = 600
        }
      }
    ]
    graphics = [
      {
        vnc = {
          autoport = true
          listeners = [
            {
              address = { address = "127.0.0.1" }
            }
          ]
        }
      }
    ]
  }
}

data "libvirt_domain_interface_addresses" "worker" {
  count      = var.worker_number
  domain     = libvirt_domain.worker-kvm[count.index].name
  source     = "any"
  depends_on = [libvirt_domain.worker-kvm]
}

resource "terraform_data" "worker-bootstrap" {
  count            = var.worker_number
  triggers_replace = [libvirt_domain.worker-kvm[count.index].uuid]

  provisioner "local-exec" {
    command = <<-EOT
      IP=${data.libvirt_domain_interface_addresses.worker[count.index].interfaces[0].addrs[0].addr} \
      NODE_TYPE=worker${count.index} \
      SERVER_IP=${data.libvirt_domain_interface_addresses.controller[0].interfaces[0].addrs[0].addr} \
      K3S_SECRET=${var.K3S_SECRET} \
      GITHUB_TOKEN=${var.GITHUB_TOKEN} \
      VAULT_TOKEN=${var.VAULT_TOKEN} \
      CLUSTER='production-${terraform.workspace}' \
      bash bootstrap.sh
    EOT
  }
}
