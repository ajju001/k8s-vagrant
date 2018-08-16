# k8s-vagrant

Setup Kubernetes Cluster with Kubeadm and Vagrant.

## Installation

```bash
git clone https://github.com/xiangweilee/k8s-vagrant
cd k8s-vagrant
vagrant up
```

## Using the cluster from your local machine

Copy the config from the master to your local machine.

```bash
scp vagrant@192.168.11.10:/etc/kubernetes/admin.conf ~/.kube/config
```

## Accessing Kubernetes Dashboard

You can access Dashboard by running the following command on your local machine.

```bash
kubectl proxy
```

Kubectl will handle authentication with apiserver and make Dashboard available at:
[http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/](http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/)

Now we need to find token we can use to log in. Execute following command:

```bash
kubectl -n kube-system describe secret `kubectl -n kube-system get secret | grep admin-user | awk '{print $1}'` | grep "token:" | awk '{print $2}'
```

Now copy the token and paste it into `Enter token` field on log in screen and click `Sign In` button.
[Imgur](https://i.imgur.com/JH1CFrx.png)
