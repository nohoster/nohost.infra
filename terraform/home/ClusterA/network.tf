resource "libvirt_network" "terraform-net" {
  name = "terraformA-net"
  mode = "nat"
  addresses = ["192.168.130.0/24"]
  autostart =true
}