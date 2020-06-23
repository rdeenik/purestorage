#!/bin/bash

helm install wordpress bitnami/wordpress --kubeconfig ./k8s-prod-config --set wordpressUsername=pureuser,wordpressPassword=pureuser,mariadb.db.password=LPQMx7l2Uj,mariadb.rootUser.password=S78JJh9rBY
helm install wordpress bitnami/wordpress --kubeconfig ./k8s-dev-config --set wordpressUsername=pureuser,wordpressPassword=pureuser,mariadb.db.password=LPQMx7l2Uj,mariadb.rootUser.password=S78JJh9rBY
