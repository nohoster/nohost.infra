resource "libvirt_network" "terraform-net" {
  name = "terraform${terraform.workspace}-net"
  mode = "nat"
  addresses = ["192.168.${terraform.workspace == "A" ? 130 : 140}.0/24"]
  autostart =true
}
