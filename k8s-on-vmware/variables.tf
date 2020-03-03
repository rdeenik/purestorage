# Generic vSphere config variables
variable "vsphere_config" {
    type                        = map(string)
    description                 = "vSphere environment and connection details"

    default = {
        user                    = "administrator@vsphere.local"
        password                = ""
        vcenter_server          = ""
        datacenter              = "datacenter"
        cluster                 = "cluster"
        datastore               = "datastore1"
        vm_network              = "VM Network"
        iscsi_network           = "iSCSI"
    }
}

# Global K8S cluster parameters
variable "k8s-global" {
    type                        = map(string)
    description                 = "Global settings for the k8s cluster"

    default = {
        username                = "k8sadmin"
        private_key             = "keys/id_rsa-k8s-on-vmware"
        public_key              = "keys/id_rsa-k8s-on-vmware.pub"
    }
}

# Admin node config parameters
variable "k8s-adminhost" {
    type                        = map(string)
    description                 = "Details for the k8s administrative node"

    default = {
        hostname                = "k8s-adminhost"
        num_cpus                = "2"
        memory                  = "1024"
        disk_size               = "20"
        template                = "ubuntu-bionic-18.04-cloudimg"
    }
}

# K8S node config parameters
variable "k8snodes" {
    type                        = map(string)
    description                 = "Details for the k8s worker nodes"

    default = {
        number_of_nodes         = "3"
        hostname                = "k8s-node"
        num_cpus                = "2"
        memory                  = "2048"
        disk_size               = "20"
        template                = "ubuntu-bionic-18.04-cloudimg"
        iscsi_subnet            = "172.16.10."
        iscsi_startip           = "101"
        iscsi_maskbits          = "24"
    }
}