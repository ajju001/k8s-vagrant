# k8s-vagrant

Setup Kubernetes Cluster with Kubeadm and Vagrant

## Installation

```bash
git clone https://github.com/xiangweilee/k8s-vagrant
cd k8s-vagrant
vagrant up
```

# Using the cluster from your local machine

Copy the config from the master to your local machine

```bash
scp vagrant@192.168.11.10:/etc/kubernetes/admin.conf ~/.kube/config
```
