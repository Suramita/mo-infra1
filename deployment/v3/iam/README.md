# Keycloak

* Make sure ingress controller is running with service type as LoadBalancer
* There is a external domain name like 'keycloak.mosip.net' that is forwarded to the LoadBalancer
* Change postgres PV policy to `Retain` if you would like to persist keycloak data. This can be achived by setting 'gp2-retain' storage class defined in `sc.yaml`.
* Update `values.yaml` appropriately
* Run
```
$ helm repo add bitnami https://charts.bitnami.com/bitnami
$ helm install keycloak bitnami/keycloak -f values.yaml
```
* While deleting helm chart note that PVC, PV do not get removed for Statefulset.  Delete them explicity if you need to.
* If you use `gp2-retain` storage class then even after deleting PVC, PV, the storage will remain intact on AWS. If you wish to delete the same, got to AWS Console --> Volumes and delete the volume.