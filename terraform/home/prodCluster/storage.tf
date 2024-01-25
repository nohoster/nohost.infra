# Define storage volume and pool
resource "libvirt_pool" "pool" {
  name = "pool${terraform.workspace}"
  type = "dir"
  path = "/home/qemu-pool${terraform.workspace}"
}
resource "libvirt_volume" "os_image" {
  name   = "ubuntu-min-qcow2"
  pool   = libvirt_pool.pool.name
  source = var.os_img_url
  format = "qcow2"
}
