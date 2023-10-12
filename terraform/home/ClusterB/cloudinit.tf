# Setup the cloudinit config files
data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
}
resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "commoninitB.iso"
  user_data      = data.template_file.user_data.rendered
  pool           = libvirt_pool.pool.name
}