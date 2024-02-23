resource "libvirt_network" "terraform-net" {
  name      = "terraform${terraform.workspace}-net"
  mode      = "nat"
  addresses = [var.network_address]
  autostart = true
}
