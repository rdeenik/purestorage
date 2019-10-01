#!/bin/bash

kubectl apply -f dashboard-user.yaml
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep pureuser | awk '{print $1}')
echo
kubectl get service/kubernetes-dashboard -n kube-system | grep kubernetes-dashboard | awk '{print "\nKubernetes dashboard: " $3}'