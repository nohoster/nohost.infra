# Setup the cloudinit config files
data "template_file" "control-user-data" {
  count    = var.control_number
  template = file("${path.module}/cloud_init.tpl")
  vars = {
    NODE_HOST       = "production-${terraform.workspace}-control${count.index}",
    TAILSCALE_TOKEN = var.TAILSCALE_TOKEN
  }
}

resource "libvirt_cloudinit_disk" "controller-init" {
  count     = var.control_number
  name      = "control${count.index}-init.iso"
  user_data = element(data.template_file.control-user-data[*].rendered, count.index)
  pool = libvirt_pool.pool.name
}

data "template_file" "worker-user-data" {
  count    = var.worker_number
  template = file("${path.module}/cloud_init.tpl")
  vars = {
    NODE_HOST       = "production-${terraform.workspace}-worker${count.index}",
    TAILSCALE_TOKEN = var.TAILSCALE_TOKEN
  }
}

resource "libvirt_cloudinit_disk" "worker-init" {
  count     = var.worker_number
  name      = "worker${count.index}-init.iso"
  user_data = element(data.template_file.worker-user-data[*].rendered, count.index)
  pool = libvirt_pool.pool.name
}
