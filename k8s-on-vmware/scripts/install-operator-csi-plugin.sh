#!/bin/bash

# Download latest helm-charts (incl. operator)
git clone --branch 5.0.0 https://github.com/purestorage/helm-charts.git

cd helm-charts/operator-csi-plugin
cp ../pure-csi/values.yaml .
vi values.yaml
./install.sh -f values.yaml
watch -n 1 kubectl get all -n pure-csi-operator