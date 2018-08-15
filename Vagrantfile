# -*- mode: ruby -*-
# vi: set ft=ruby :

BOX_IMAGE = "centos/7"
BOX_VERSION = "1804.02"
SETUP_MASTER = true
SETUP_NODES = true
NODE_COUNT = 1
MASTER_IP = "192.168.11.10"
NODE_IP = "192.168.11."
K8S_DASHBOARD = true

TOKEN = "zt6k1w.nxvhgrzj9jqg0g6n"

$master_script = <<MASTERSCRIPT
# Initialize the master
kubeadm reset --force
kubeadm init --apiserver-advertise-address=#{MASTER_IP} --token #{TOKEN} --token-ttl 0

# Copy config files
sudo chmod 644 /etc/kubernetes/admin.conf
mkdir -p $HOME/.kube
sudo cp -Rf /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Setup the container network
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
MASTERSCRIPT

$node_script = <<NODESCRIPT
# Register node to master
kubeadm reset --force
kubeadm join #{MASTER_IP}:6443 --token #{TOKEN} --discovery-token-unsafe-skip-ca-verification
NODESCRIPT

$k8s_dashboard_script= <<K8SDASHSCRIPT
# Deploy k8s dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
kubectl apply -f /vagrant/yaml/admin-user.yaml
K8SDASHSCRIPT

Vagrant.configure("2") do |config|
  config.vm.box = BOX_IMAGE
  config.vm.box_version = BOX_VERSION
  config.vm.box_check_update = false

  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--memory", "2048"]
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  end

  if SETUP_MASTER
    config.vm.define "master" do |master|
      master.vm.hostname = "master.k8s"
      master.vm.network "private_network", ip: MASTER_IP
      master.vm.provision "shell" do |s|
        s.inline = "sed 's/127.0.0.1.*'$2'/'$1' '$2'/' -i /etc/hosts"
        s.args = [MASTER_IP, master.vm.hostname]
      end
      master.vm.provision :shell, inline: $master_script
      if K8S_DASHBOARD
        master.vm.provision :shell, inline: $k8s_dashboard_script
      end
    end
  end

  if SETUP_NODES
    (1..NODE_COUNT).each do |i|
      config.vm.define "node#{i}" do |node|
        node.vm.hostname = "node#{i}.k8s"
        node.vm.network "private_network", ip: NODE_IP + "#{i + 10}"
        node.vm.provision :shell, inline: $node_script

        # See https://stackoverflow.com/questions/39869583/how-to-get-kube-dns-working-in-vagrant-cluster-using-kubeadm-and-weave
        node.vm.provision "shell" do |s|
          s.inline = "sed 's/127.0.0.1.*'$2'/'$1' '$2'/' -i /etc/hosts"
          s.args = [NODE_IP + "#{i + 10}", node.vm.hostname]
        end
        node.vm.provision :shell, :inline => "route add 10.96.0.1 gw #{MASTER_IP}", run: "always"
      end
    end
  end

  config.vm.provision "shell", path: "init.sh"
end
