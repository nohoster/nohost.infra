# Nohost.network infrastructure config files.

This repo contains all the files required to create the cluster in which the nohost services are located. Everything is completely automated and with just a single terraform init command \
you can have a fully functional production server.

The **Terraform** contains all the IaaC configs. The home/prodCluster is the production cluster running at my homelab. It uses libvirt with KVM/QEMU to create 3 virtual servers. \
Inside the oracle are the servers user Oracle Cloud services. Staging is my staging server to test configs before pushing to production. It's exactly the same as the production server \
just with minor config changes, mainly in certmanager and monitoring. The build is a clean cluster to build and test CI pipelines, mainly in Jenkins.

The server configuration is done through Ansible and Bash and is located in the ansible directory. Tasks is for the Ansible tasks and templates for the Kubernetes manifests \
needed to bootstrap the server.

To see how the production Kubernetes cluster is configured, check the [nohost.network](https://github.com/nohoster/nohost.network) repository. \
Some backend service configurations are in [nohost.backend](https://github.com/nohoster/nohost.backend) repository and \
CI pipelines are in each app project repository.


