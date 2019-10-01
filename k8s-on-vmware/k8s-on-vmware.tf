# Inspired by https://sdorsett.github.io/post/2018-12-26-using-local-exec-and-remote-exec-provisioners-with-terraform/
# To Do:
# - Install kubectl
# - Copy config from master node (.kube/config)
# - set fixed IP addresses (at least for iSCSI)
# - Testing...
#
#
#
#

provider "vsphere" {
  # vSphere credentials
  user           = "${var.vsphere_config.user}"
  password       = "${var.vsphere_config.password}"
  vsphere_server = "${var.vsphere_config.vcenter_url}"

  # Allow a self-signed certificate
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "${var.vsphere_config.datacenter}"
}

data "vsphere_datastore" "datastore" {
  name          = "${var.vsphere_config.datastore}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_resource_pool" "pool" {
  name          = "${var.vsphere_config.resourcepool}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "vm_network" {
  name          = "${var.vsphere_config.vm_network}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "iscsi_network" {
  name          = "${var.vsphere_config.iscsi_network}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "k8s-adminnode" {
  name             = "${var.k8s-adminnode.hostname}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"

  num_cpus = "${var.k8s-adminnode.num_cpus}"
  memory   = "${var.k8s-adminnode.memory}"
  guest_id = "ubuntu64Guest"

  network_interface {
    network_id = "${data.vsphere_network.vm_network.id}"
  }

  disk {
    label = "disk0"
    size  = "${var.k8s-adminnode.disk_size}"
  }

  cdrom {
    datastore_id     = "${data.vsphere_datastore.datastore.id}"
    path             = "${var.k8s-adminnode.iso_location}"
  }
  
  wait_for_guest_net_timeout = 60
}

resource "vsphere_virtual_machine" "k8s-nodes" {
  count            = "${var.k8s-nodes.number_of_nodes}"
  name             = "${var.k8s-nodes.hostname}${count.index + 1}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"

  num_cpus = "${var.k8s-nodes.num_cpus}"
  memory   = "${var.k8s-nodes.memory}"
  guest_id = "ubuntu64Guest"

  network_interface {
    network_id = "${data.vsphere_network.vm_network.id}"
  }

  network_interface {
    network_id = "${data.vsphere_network.iscsi_network.id}"
  }

  disk {
    label = "disk0"
    size  = "${var.k8s-nodes.disk_size}"
  }

  cdrom {
    datastore_id     = "${data.vsphere_datastore.datastore.id}"
    path             = "${var.k8s-nodes.iso_location}"
  }

  # Allow ten minutes for the deployment and installation of the VMs
  wait_for_guest_net_timeout = 10
}

resource "null_resource" "nodes" {
  #triggers = {
  #   build_number = "${timestamp()}"
  #}

  count = "${var.k8s-nodes.number_of_nodes}"

  connection {
    type = "ssh"
    host = "${vsphere_virtual_machine.k8s-nodes[count.index].default_ip_address}"
    user = "root"
    private_key = "${file("/Users/rdeenik/.ssh/id_rsa-k8s-on-vmware")}"
    port = "22"
    agent = false
  }

  provisioner "file" {
    source          = "${var.k8s-adminnode.public_key}"
    destination     = "/tmp/id_rsa.pub"
  }
  
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /root/.ssh/",
      "chmod 700 /root/.ssh",
      "cat /tmp/id_rsa.pub >> /root/.ssh/authorized_keys",
      "rm -f /tmp/id_rsa.pub",
      "chmod 600 /root/.ssh/authorized_keys",
      "sed -i 's/PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config",
      "service sshd restart",
      "apt -y install vim net-tools open-iscsi multipath-tools",
      "update-rc.d iscsid enable",
      "service iscsid start",
      "passwd -dl root",
      "echo \"    ens224:\">>/etc/netplan/01-netcfg.yaml",
      "echo \"      dhcp4: no\">>/etc/netplan/01-netcfg.yaml",
      "echo \"      addresses: [${var.k8s-nodes.iscsi_subnet}${var.k8s-nodes.iscsi_startip + count.index}/${var.k8s-nodes.iscsi_maskbits}]\">>/etc/netplan/01-netcfg.yaml",
      "netplan apply"
    ]
  }
}

resource "null_resource" "adminnode" {
  #triggers = {
  #  build_number = "${timestamp()}"
  #}

  connection {
    type = "ssh"
    host = "${vsphere_virtual_machine.k8s-adminnode.default_ip_address}"
    user = "root"
    private_key = "${file("/Users/rdeenik/.ssh/id_rsa-k8s-on-vmware")}"
    port = "22"
    agent = false
  }

  provisioner "file" {
    source          = "${var.k8s-adminnode.public_key}"
    destination     = "/tmp/id_rsa.pub"
  }
  
  provisioner "file" {
    source          = "${var.k8s-adminnode.private_key}"
    destination     = "/tmp/id_rsa"
  }

  provisioner "remote-exec" {
    inline = [
      "echo '127.0.0.1 ${var.k8s-adminnode.hostname}' | sudo tee -a /etc/hosts",
      "sudo hostnamectl set-hostname ${var.k8s-adminnode.hostname}",
      "mkdir -p /root/.ssh/",
      "chmod 700 /root/.ssh",
      "mv /tmp/id_rsa /root/.ssh/",
      "chmod 600 /root/.ssh/id_rsa",
      "mv /tmp/id_rsa.pub /root/.ssh/",
      "cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys",
      "chmod 600 /root/.ssh/authorized_keys",
      "sed -i 's/PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config",
      "service sshd restart",
      "passwd -dl root",
      "apt -y install python3-pip git vim net-tools curl",
      "pip3 install --upgrade pip",
      "curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl",
      "chmod +x kubectl",
      "sudo mv kubectl /usr/local/bin/",
      "git clone https://github.com/kubernetes-sigs/kubespray.git",
      "cd kubespray",
      "sudo pip install -r requirements.txt",
      "cp -rfp inventory/sample inventory/k8s-on-vmware",
      "echo ${join(" ", vsphere_virtual_machine.k8s-nodes.*.default_ip_address)} >/tmp/ips",
      "echo \"#!/bin/bash\" >/tmp/kubespray.sh",
      "echo \"declare -a IPS=(`cat /tmp/ips`)\" >>/tmp/kubespray.sh",
      "echo \"CONFIG_FILE=inventory/k8s-on-vmware/hosts.yml python3 contrib/inventory_builder/inventory.py \\$${IPS[@]}\" >>/tmp/kubespray.sh",
      "echo \"ansible-playbook -i inventory/k8s-on-vmware/hosts.yml --become --become-user=root cluster.yml\" >>/tmp/kubespray.sh",
      "chmod +x /tmp/kubespray.sh",
      "/tmp/kubespray.sh",
      "cd ~",
      "mkdir .kube",
      "scp -oStrictHostKeyChecking=no ${vsphere_virtual_machine.k8s-nodes[0].default_ip_address}:/etc/kubernetes/admin.conf .kube/config"
    ]
  }
  depends_on = [null_resource.nodes]
}

resource "null_resource" "k8s-config" {
  triggers = {
    build_number = "${timestamp()}"
  }

  connection {
    type = "ssh"
    host = "${vsphere_virtual_machine.k8s-adminnode.default_ip_address}"
    user = "root"
    private_key = "${file("/Users/rdeenik/.ssh/id_rsa-k8s-on-vmware")}"
    port = "22"
    agent = false
  }

  provisioner "file" {
    source      = "examples"
    destination = "~/"
  }

  provisioner "file" {
    source      = "scripts"
    destination = "~/"
  }

  #provisioner "remote-exec" {
  #  inline = [
  #    "mkdir examples",
  #  ]
  #}
  depends_on = [null_resource.adminnode]
}