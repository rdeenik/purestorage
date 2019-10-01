resource "null_resource" "generate-sshkey" {
    provisioner "local-exec" {
        command = "yes y | ssh-keygen -b 4096 -t rsa -C 'k8s-on-vmware-sshkey' -N '' -f ${var.k8s-adminnode.private_key}"
    }
}