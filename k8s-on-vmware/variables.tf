variable "vsphere_config" {
    type                        = "map"
    description                 = "vSphere environment and connection details"

    default = {
        user            = "administrator@vsphere.local"
        password        = ""
        vcenter_url     = "localhost"
        datacenter      = "datacenter"
        resourcepool    = "Cluster/Resources"
        datastore       = "datastore1"
        vm_network      = "VM Network"
        iscsi_network   = "iSCSI"
    }
}

variable "k8s-adminnode" {
    type                        = "map"
    description                 = "Details for the k8s administrative node"

    default = {
        hostname                = "k8s-adminnode"
        num_cpus                = "2"
        memory                  = "1024"
        disk_size               = "20"
        iso_location            = "iso/ubuntu-18.04-netboot-amd64-unattended.iso"
        private_key             = "~/.ssh/id_rsa-k8s-on-vmware"
        public_key              = "~/.ssh/id_rsa-k8s-on-vmware.pub"
    }
}

variable "k8s-nodes" {
    type                        = "map"
    description                 = "Details for the k8s worker nodes"

    default = {
        number_of_nodes         = "3"
        hostname                = "k8s-node"
        num_cpus                = "2"
        memory                  = "2048"
        disk_size               = "20"
        iso_location            = "iso/ubuntu-18.04-netboot-amd64-unattended.iso"
        iscsi_subnet            = "172.16.1."
        iscsi_startip           = "11"
        iscsi_maskbits          = "24"
    }
}