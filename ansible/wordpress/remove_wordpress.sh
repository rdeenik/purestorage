#!/bin/bash

helm delete wordpress --kubeconfig ./k8s-prod-config
kubectl delete pvc --all --kubeconfig ./k8s-prod-config
helm delete wordpress --kubeconfig ./k8s-dev-config
kubectl delete pvc --all --kubeconfig ./k8s-dev-config

