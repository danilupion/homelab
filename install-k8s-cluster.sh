#!/usr/bin/env bash
set -e

# Install dependencies
apt-get update && apt-get upgrade -y
apt-get install -y apt-transport-https ca-certificates curl gpg software-properties-common lsb-release vim git wget jq

# Disable swap and make it permanent after reboot
swapoff -a
systemctl stop dev-sda2.swap
systemctl disable dev-sda2.swap
sed -i '/ swap / s/^/#/' /etc/fstab

# Load Modules needed for containerd, also persist across reboots
modprobe overlay
modprobe br_netfilter

cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

# Set up required sysctl params, these persist across reboots.
cat <<EOF | tee /etc/sysctl.d/99-kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF

# Ensure the changes are used by the current kernel
sysctl --system

# Install containerd
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update && apt-get install containerd.io -y
containerd config default | tee /etc/containerd/config.toml
sed -e 's/SystemdCgroup = false/SystemdCgroup = true/g' -i /etc/containerd/config.toml
sed -e 's|sandbox_image = "registry.k8s.io/pause:3.6"|sandbox_image = "registry.k8s.io/pause:3.9"|g' -i /etc/containerd/config.toml

systemctl restart containerd

# Install kubernetes (1.29.2)
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubelet="1.29.2-1.1" kubectl="1.29.2-1.1" kubeadm="1.29.2-1.1"
apt-mark hold kubelet kubeadm kubectl

# Configure containerd for k8s
crictl config --set runtime-endpoint=unix:///run/containerd/containerd.sock --set image-endpoint=unix:///run/containerd/containerd.sock

# Pull pause image
crictl pull registry.k8s.io/pause:3.9
kubeadm init

# Make cluster accessible from host
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

# Allow pods to run on the control-plane node
kubectl taint nodes $(kubectl get nodes -o jsonpath='{.items[0].metadata.name}') node-role.kubernetes.io/control-plane:NoSchedule-

# Install helm (3.14.0)
ARCH=$(uname -m)
case $ARCH in
    x86_64)
        ARCH="amd64"
        ;;
    armv6l | armv7l)
        ARCH="arm"
        ;;
    aarch64)
        ARCH="arm64"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

mkdir -p /homelab/config/prowlarr
mkdir -p /homelab/config/radarr
mkdir -p /homelab/config/wireguard

chown -R 1000:1000 /homelab/config