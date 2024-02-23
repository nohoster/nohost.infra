#cloud-config
# #

hostname: ${ NODE_HOST }

ssh_pwauth: False

ssh_authorized_keys:
  - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDPOxZNsBJHcI/TUnr6aIy4YxkVl65go4YJLs8x64u2JQLCh+c71xxnA/g3Q/7C3U1X3iuiaG5STe7OHzkp7SNN8UQVVuazNbO393XZuBEKNweHxpjCB35jtktYfVxZLHwTJVTyHzwcNWFUnrDVYQE2affeETK0SgQymyP7CPwe2KCaedSm6WYf1S6OeuQYcVArkqb2TJnWtn0VOgyv3OSSdyTpPz39gUQGJIVzqsf1AFjh52idgX2EA67X4w1/ghiyB+s2D3vhMfNUMskZ6pYmuxYNXFgzKi2/Bqu1VC/aIwZJ33czH8/U6Vdu+/s6NfTuMvlURdvtqeKgXY1DrY0F 

ssh_quiet_keygen: true
ssh_genkeytypes: [rsa, dsa, ecdsa, ed25519]

runcmd:
  - curl -fsSL https://tailscale.com/install.sh | sh
  - tailscale up --login-server https://scale01.nohost.network --auth-key ${ TAILSCALE_TOKEN }
