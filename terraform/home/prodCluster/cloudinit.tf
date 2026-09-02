# Setup the cloudinit config files
resource "libvirt_cloudinit_disk" "controller-init" {
  count = var.control_number
  name  = "control${count.index}-init.iso"

  user_data = "#cloud-config\n${yamlencode(
    {
      ssh_pwauth = false
      ssh_authorized_keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDPOxZNsBJHcI/TUnr6aIy4YxkVl65go4YJLs8x64u2JQLCh+c71xxnA/g3Q/7C3U1X3iuiaG5STe7OHzkp7SNN8UQVVuazNbO393XZuBEKNweHxpjCB35jtktYfVxZLHwTJVTyHzwcNWFUnrDVYQE2affeETK0SgQymyP7CPwe2KCaedSm6WYf1S6OeuQYcVArkqb2TJnWtn0VOgyv3OSSdyTpPz39gUQGJIVzqsf1AFjh52idgX2EA67X4w1/ghiyB+s2D3vhMfNUMskZ6pYmuxYNXFgzKi2/Bqu1VC/aIwZJ33czH8/U6Vdu+/s6NfTuMvlURdvtqeKgXY1DrY0F"
      ]
      chpasswd = {
        expire = false
        users = [
          {
            name     = "ubuntu"
            password = "$6$rounds=4096$fJOYQ5VowCs2fj17$KP4LBQCh0UKcOBvkvolILVZA19hhUcH613DlKJU8mNkfLosNP37an0kQVbr/BPIQ2lqEiSE5wgAgTKxzBFZfZ/"
          }
        ]
      }
      ssh_quiet_keygen = true
      ssh_genkeytypes  = ["rsa", "dsa", "ecdsa", "ed25519"]
    }
  )}"

  meta_data = yamlencode({
    instance-id    = "production-${terraform.workspace}-control${count.index}"
    local-hostname = "production-${terraform.workspace}-control${count.index}"
  })
}

resource "libvirt_volume" "controller-cloudinit" {
  count = var.control_number
  name  = "control${count.index}-init.iso"
  pool  = libvirt_pool.pool.name
  target = {
    format = {
      type = "iso"
    }
  }
  create = {
    content = {
      url = libvirt_cloudinit_disk.controller-init[count.index].path
    }
  }

  lifecycle {
    replace_triggered_by = [libvirt_cloudinit_disk.controller-init[count.index]]
  }
}

resource "libvirt_cloudinit_disk" "worker-init" {
  count = var.worker_number
  name  = "worker${count.index}-init.iso"

  user_data = "#cloud-config\n${yamlencode(
    {
      ssh_pwauth = false
      ssh_authorized_keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDPOxZNsBJHcI/TUnr6aIy4YxkVl65go4YJLs8x64u2JQLCh+c71xxnA/g3Q/7C3U1X3iuiaG5STe7OHzkp7SNN8UQVVuazNbO393XZuBEKNweHxpjCB35jtktYfVxZLHwTJVTyHzwcNWFUnrDVYQE2affeETK0SgQymyP7CPwe2KCaedSm6WYf1S6OeuQYcVArkqb2TJnWtn0VOgyv3OSSdyTpPz39gUQGJIVzqsf1AFjh52idgX2EA67X4w1/ghiyB+s2D3vhMfNUMskZ6pYmuxYNXFgzKi2/Bqu1VC/aIwZJ33czH8/U6Vdu+/s6NfTuMvlURdvtqeKgXY1DrY0F"
      ]
      ssh_quiet_keygen = true
      ssh_genkeytypes  = ["rsa", "dsa", "ecdsa", "ed25519"]
    }
  )}"

  meta_data = yamlencode({
    instance-id    = "production-${terraform.workspace}-worker${count.index}"
    local-hostname = "production-${terraform.workspace}-worker${count.index}"
  })
}

resource "libvirt_volume" "worker-cloudinit" {
  count = var.worker_number
  name  = "worker${count.index}-init.iso"
  pool  = libvirt_pool.pool.name
  target = {
    format = {
      type = "iso"
    }
  }
  create = {
    content = {
      url = libvirt_cloudinit_disk.worker-init[count.index].path
    }
  }

  lifecycle {
    replace_triggered_by = [libvirt_cloudinit_disk.worker-init[count.index]]
  }
}
