#!/bin/bash

ssh_status() {
  ssh -o StrictHostKeyChecking=off -o BatchMode=yes -o ConnectTimeout=5 -q ubuntu@$IP echo "Server ready" 2>&1
}
# Wait for VM to be ready 
while ssh_status; ss=$?; [ $ss != 0 ]; do
  echo Server $NODE_TYPE at $IP not ready
  sleep 5
done

# Setup config
ansible-playbook -i "$IP," --extra-vars "NODE_TYPE=$NODE_TYPE CLUSTER=$CLUSTER" ../../../ansible/nohost-home-bootstrap.yaml

## Bootstrap k3s
if [[ $NODE_TYPE =~ "worker" ]]; then
  ansible all -b -u ubuntu -i "$IP," -m shell -a "curl -sfL https://get.k3s.io | K3S_TOKEN=$K3S_SECRET sh -s - agent --server https://$SERVER_IP:6443"
fi

if [[ $NODE_TYPE =~ "control0" ]]; then
  ansible all -b -u ubuntu -i "$IP," -m shell -a "curl -sfL https://get.k3s.io | K3S_TOKEN=$K3S_SECRET sh -s - server --cluster-init --disable-kube-proxy --flannel-backend=none --cluster-cidr=10.42.0.0/16 --disable-network-policy --disable=local-storage"
  ansible all -b -u ubuntu -i "$IP," -m fetch -a 'src=/etc/rancher/k3s/k3s.yaml flat=true dest=~/.kube/nohost-$CLUSTER'

#TODO add HA support
#elif [[ $NODE_TYPE =~ "control"* ]]; then

fi  
