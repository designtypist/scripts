# HW requirements: 2 CPUS 2 RAM
# OS: Ubuntu focal
set -ex

#should be $(lsb_release -cs) but it appears it is not working on focal yet
docker_ubuntu_release=bionic
k8s_version=1.18.0

# Set hostname
sudo hostnamectl set-hostname "$(hostname -I | awk '{print $1}')"
echo "export PS1=\"\[\e[1;35m\]\u\[\033[m\]@\[\e[1;92m\]$(hostname -I | awk '{print $1}')\[\033[m\]:\w \$ \"" >>~/.bashrc

# disable swap
sudo swapoff -a && sudo sed -i 's/\/swap/#\/swap/g' /etc/fstab

############# install docker & k8s

## install docker, kubelet, kubeadm and kubectl
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $docker_ubuntu_release \
  stable"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

sudo apt-get update
sudo apt-get install -y \
  containerd.io=1.2.13-1 \
  docker-ce=5:19.03.8~3-0~ubuntu-$docker_ubuntu_release \
  docker-ce-cli=5:19.03.8~3-0~ubuntu-$docker_ubuntu_release
sudo apt-get install -y kubelet=$k8s_version-00 kubeadm=$k8s_version-00 kubectl=$k8s_version-00
sudo apt-mark hold docker-ce kubelet kubeadm kubectl

echo "net.bridge.bridge-nf-call-iptables=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

## configure docker

cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

sudo mkdir -p /etc/systemd/system/docker.service.d

sudo systemctl daemon-reload
sudo systemctl restart docker

############# configure kubeadm (master only)

sudo kubeadm init # --pod-network-cidr=10.244.0.0/16 | tee ~/kubeadm.log

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown "$(id -u):$(id -g)" $HOME/.kube/config

## install flannel network
#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/485649719be5a21b0fe7e44f699f7acbb66137fa/Documentation/kube-flannel.yml
