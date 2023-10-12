# Define storage volume and pool
resource "libvirt_pool" "pool" {
  name = "poolB"
  type = "dir"
  path = "/home/qemu-poolB"
}
resource "libvirt_volume" "os_image" {
  name   = "ubuntu-min-qcow2"
  pool   = libvirt_pool.pool.name
  source = var.os_img_url
  format = "qcow2"
}