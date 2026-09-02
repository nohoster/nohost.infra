# Define storage volume and pool
resource "libvirt_pool" "pool" {
  name = "pool${terraform.workspace}"
  type = "dir"
  target = {
    path = "/vm-pools/qemu-pool${terraform.workspace}"
  }
}
resource "libvirt_volume" "os_image" {
  name = "ubuntu-min-qcow2"
  pool = libvirt_pool.pool.name
  create = {
    content = {
      url = var.os_img_url
    }
  }
  target = {
    format = {
      type = "qcow2"
    }
  }
}
