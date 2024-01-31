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
ansible-playbook -i "$IP," ../../../ansible/build-bootstrap.yaml

# Bootstrap k3s
if [[ $NODE_TYPE =~ "worker" ]]; then
k3sup join --ip $IP --server-ip $SERVER_IP --user ubuntu
fi
if [[ $NODE_TYPE == "control0" ]]; then
k3sup install --ip $IP\
        --user ubuntu \
        --cluster \
        --k3s-channel=stable \
        --k3s-extra-args "--disable-kube-proxy --flannel-backend=none --cluster-cidr=10.42.0.0/16 --disable-network-policy" \
        --local-path $HOME/.kube/nohost-$CLUSTER
elif [[ $NODE_TYPE =~ "control"* ]]; then
k3sup install --ip $IP \
        --user ubuntu \
        --server \
        --server-ip $SERVER_IP
        --k3s-channel=stable \
        --k3s-extra-args "--disable-kube-proxy --flannel-backend=none --cluster-cidr=10.42.0.0/16 --disable-network-policy" \
        --local-path $HOME/.kube/nohost-$CLUSTER
fi
