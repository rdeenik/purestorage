# A set of Ansible playbook examples.

## Hybrid Cloud playbooks - Cloning volumes using FlashArray/Cloud Block Store and PSO to import volumes in Kubernetes

[fa_clone_vol_to_remote_array.yaml](fa_clone_vol_to_remote_array.yaml)
This playbook replicates a volume snapshot on a FlashArray to an other FlashArray and waits until the replication has completed and then copy's the remote snapshot into a new volume, which can then be used for Dev/Test.
More detailed description here: https://d-nix.nl/2019/08/using-ansible-for-hybrid-cloud-devops/

[fa_k8s_mysql_deployments_from_volume.yaml](fa_k8s_mysql_deployments_from_volume.yaml)
This playbook is a follow-up on the one above, and uses the new volume to create even some more volumes and import thos new volumes into Kubernetes using the Pure Service Orchestrator as Persistent Volume Claims (PVCs) and deploy some MySQL pods that use these PVCs.
More detailed description here: https://d-nix.nl/2019/08/using-ansible-for-hybrid-cloud-devops/

[cleanup_k8s_mysql_deployments.yaml](cleanup_k8s_mysql_deployments.yaml)
This playbook is used to clean-up after the previous two. Removing the Kubernetes deployments and PVCs.

## Create snapshots for Kubernetes volumes on FlashArray/Cloud Block Store

[pso_async_replication.yaml](pso_async_replication.yaml)
This playbook will find all volumes created by PSO on the FlashArray/CBS using the namespace.pure prefix used by PSO, add all the volumes to a protection group and (if desired) create a snapshot. The snapshot will only be created if new volumes have been added.
More detailed description here: https://d-nix.nl/2019/10/snapshot-protection-for-pso-using-ansible/
