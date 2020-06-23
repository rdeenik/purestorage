watch -n 1 'kubectl get all,pvc --kubeconfig ./k8s-prod-config; echo "----------------------------------"; kubectl get all,pvc --kubeconfig ./k8s-dev-config'
