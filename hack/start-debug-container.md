
```sh
evil_pod_name=$(kubectl get pod -l app=evil --no-headers -o jsonpath="{.items[0].metadata.name}")
kubectl debug -it $evil_pod_name --image=busybox:latest --target=evil-service
kubectl debug -it node/kind-control-plane --image=ubuntu


curl -i http://127.0.0.1/evil/hello
kubectl logs $evil_pod_name --follow

```
