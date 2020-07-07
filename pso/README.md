# Information on the Pure Service Orchestrator (PSO)
Some notes of my own on the Pure Storage - Pure Service Orchestrator (PSO) product

## Troubleshooting steps for PSO





kubectl describe pod/wordpress-mysql-0

MountVolume.MountDevice failed for volume "pvc-dec0f485-ca43-4be4-b2a1-a3f59834f817" : rpc error: code = Internal desc = Failed to log in to any iSCSI targets! Will not be able to attach volume
Unable to attach or mount volumes: unmounted volumes=[mysql-persistent-storage], unattached volumes=[mysql-persistent-storage default-token-zzbtd]: timed out waiting for the condition
MountVolume.MountDevice failed for volume "pvc-dec0f485-ca43-4be4-b2a1-a3f59834f817" : rpc error: code = DeadlineExceeded desc = context deadline exceeded