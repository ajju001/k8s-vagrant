#!/bin/bash

# Disabling selinux
sed -i s/^SELINUX=.*$/SELINUX=permissive/ /etc/selinux/config
setenforce 0

# Disabling the firewall
systemctl disable firewalld && systemctl stop firewalld

# Adding the kubernetes yum repo
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://yum.kubernetes.io/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

# Install docker, kubelet, kubeadm, kubectl, and kubenetes-cni
yum install -y docker kubelet kubeadm kubectl kubernetes-cni net-tools
systemctl enable docker && systemctl start docker
systemctl enable kubelet && systemctl start kubelet

# Enabling the net.bridge.bridge-nf-call-iptables kernel option
sysctl -w net.bridge.bridge-nf-call-iptables=1
echo "net.bridge.bridge-nf-call-iptables=1" > /etc/sysctl.d/k8s.conf

# Disabling swap
swapoff -a &&  sed -i '/ swap / s/^/#/' /etc/fstab
