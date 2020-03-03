# Welcome to this Kubernetes-on-VMware project.

## Requirements
Ubuntu ova template, tested with 18.04 (https://cloud-images.ubuntu.com/)

## Installation

**Download**<br/>
```bash
git clone https://github.com/dnix101/purestorage.git
cd purestorage/k8s-on-vmware/
```

**Configure**<br/>
```bash
vi variables.tf
```

**Deploy**<br/>
```bash
terraform init
terraform plan
terraform apply
```
