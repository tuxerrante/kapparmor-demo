## 0
- `tests/cm-test-00.yml`  
  App profiled with 'deny /bin/** w'  
  Can it be deleted?

## 1
- `tests/cm-test-01.yml`  
  App profiled with 'deny /bin/** w'  

Can't be deleted.
Expected error:
```
[failed to "KillContainer" for "evil-service" with KillContainerError: "rpc error: code = Unknown desc = failed to stop container \"...\": unknown error after kill: /usr/bin/runc did not terminate successfully: exit status 1: container_linux.go:419: signaling init process caused: permission denied\n: unknown"]
```

Solution:
```sh
kubectl delete cm kapparmor-profiles
kubectl apply -f tests/cm-test-00.yml
```

## 2
- `tests/cm-test-02.yml`  

```sh
kubectl delete cm kapparmor-profiles
kubectl apply -f tests/cm-test-02.yml
kubectl get cm kapparmor-profiles -o yaml |less

```

```
kubectl debug node/aks-agentpool-29737789-vmss00000a -it --image=mcr.microsoft.com/dotnet/runtime-deps:6.0 
```



## 3
- `tests/cm-test-03.yml`  



## FAQ:
- How to proceed to update a profiled deployment?
  You should first delete the profile from the configmap, be sure no other app is using that one, than you can delete or upgrade the deployment.
  You could also put that policy in audit mode, but at the moment there is no way to send a request to the daemonset to do that.

- How to remove profiles from the configmap?
  Applying an empty configmap with the same name doesn't change the remote resource.
  It should be deleted and re-created?

- What happens if you delete the profiles configmap?
  The app will continue to work since the volume inside the pod will continue to exist with previously loaded profiles.
  Also K8S will start complaining with Warning events.

- How big could be a configmap?


## Debugging
```sh
kubectl apply -f deploy/evil_deployment_profiled.yaml
kubectl port-forward services/evil 8090:8090

# Delete the profiles deployment
kubectl delete cm kapparmor-profiles;  kubectl apply -f tests/cm-test-00.yml; kubectl delete deploy/evil
# kubectl get cm kapparmor-profiles -o yaml |less
# Wait a 4 minutes for the profile to be unloaded by the kernel

# ----

kubectl delete cm kapparmor-profiles;  kubectl apply -f tests/cm-test-03.yml; kubectl apply -f deploy/evil_deployment_profiled.yaml
```