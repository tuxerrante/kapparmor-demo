Call the service and check it is running:
```sh
curl -i http://127.0.0.1/evil/hello
```

In a real cluster the write operation would end up in the node filesystem, in Kind the container layer has to be mapped on the host machine to make write operations succeed, so you will find the new file in the virtual machine /bin directory.
```sh
evil_pod_name=$(kubectl get pod -l app=evil --no-headers -o jsonpath="{.items[0].metadata.name}")
kubectl logs $evil_pod_name --follow
# kubectl debug -it $evil_pod_name --image=busybox:latest --target=evil-service
# kubectl debug -it node/kind-control-plane --image=ubuntu

# On the Host machine
ls -l /bin/evil
cat /bin/evil
```

```yml
kubectl apply -f deploy/cm-kapparmor-profiles.yml
kubectl logs kapparmor

# terminal 1
# kubectl patch deployment evil -p '{"spec": {"template":{"metadata":{"annotations":{"container.apparmor.security.beta.kubernetes.io/evil-service":"localhost/custom.deny-write-root"}}}} }'
sudo rm /bin/evil
kubectl apply -f deploy/evil_deployment_profiled.yaml
kubectl rollout restart deployment evil
watch -n 1 ls -t /bin/

# terminal 2
kubectl get deployments.apps evil -w

# terminal 3
curl http://127.0.0.1/evil/hello

kubectl get events --sort-by .lastTimestamp
```

The pod should start again one we deactivate the profile, putting it in complain mode:
```sh
less /var/log/syslog    # search for deny-write-root 
sudo aa-complain /etc/apparmor.d/custom/custom.deny-write-root
kubectl rollout restart deployment evil
```

Or we can patch the deployment with a safer image and restart
```sh
kubectl patch deployment evil  -p '{"spec":{"template":{"spec":{"containers":[{"name":"evil-service","image":"teamsis2022/evil-service:1.0.1-safe"}]}}}}'

```

### Extra
Clean profiles
```sh
# Get and clean the file
mkdir /tmp/custom-profiles
# kubectl get cm kapparmor-profiles -o jsonpath='{.data}' |jq
kubectl get cm kapparmor-profiles -o jsonpath='{.data.custom\.deny-write-outside-app}' > /tmp/custom-profiles/custom.deny-write-outside-app
kubectl get cm kapparmor-profiles -o jsonpath='{.data.custom\.deny-write-outside-home}' > /tmp/custom-profiles/custom.deny-write-outside-home
kubectl get cm kapparmor-profiles -o jsonpath='{.data.custom\.deny-write-root}' > /tmp/custom-profiles/custom.deny-write-root

sudo apparmor_parser --remove /tmp/custom-profiles/*
sudo rm /etc/apparmor.d/custom/custom*
kubectl rollout restart daemonset kapparmor
ls -la /etc/apparmor.d/custom/
```