#!/bin/bash
# Environment info
kubectl get nodes

# Install/upgrade Kapparmor
helm repo add tuxerrante https://tuxerrante.github.io/kapparmor
helm upgrade --install kapparmor --install --atomic --timeout 120s --debug --set image.tag=v0.1.5 tuxerrante/kapparmor

# Is Kapparmor running?
k get deploy
k get ds
k get ds kapparmor -o yaml |less

# Have a look at the current profiles
k get cm kapparmor-profiles -o yaml |less

kapparmor_pod="$(k get po --no-headers -o custom-columns=":metadata.name" |grep kapparmor |head -1)"

k exec -ti $kapparmor_pod -- ls -l /etc/apparmor.d/custom 

# All profiles on the node
k exec -ti $kapparmor_pod -- cat /sys/kernel/security/apparmor/profiles

# Deploy a testing malicious app
kubectl delete deployment evil | 
    kubectl apply -f deploy/evil_deployment.yaml

kubectl create service clusterip --tcp=8090:8090 --insecure-skip-tls-verify=true evil

k get deploy evil -o yaml |less

# Terminal 3: Follow app logs
kubectl logs deployments/evil -c evil-service --follow

# Terminal 1: Open a tunnel to the service
kubectl port-forward services/evil 8090:8090
# Terminal 2: Invoke the service
export EVIL_ADDRESS=http://localhost:8090/
curl -iL ${EVIL_ADDRESS}/hello

# Fast look at the app code

# We have to stop that evil message!
#   ...and also writing access to bin
kubectl apply -f tests/deny-bin-write.yml

# If we annotate the deployment TEMPLATE with the security profile
#   the new pods will be stuck in a CrashLoop and the old ones will stay alive
# kubectl patch deployment evil -p '
#     {"spec":
#         {"template":
#             {"metadata":
#                 {"annotations":
#                     {"container.apparmor.security.beta.kubernetes.io/evil-service": "localhost/custom.deny-bin-write"}
#                 }
#             }
#         }
#     }'

# New pods have to be created in order to inherit the new template
kubectl delete deploy evil
kubectl apply -f deploy/evil_deployment_profiled.yaml
kubectl port-forward services/evil 8090:8090

# --> Pods can't start anymore since they're trying to mount /bin in writing access!
evil_pod="$(k get po --no-headers -o custom-columns=":metadata.name" |grep evil |head -1)"
k describe pod $evil_pod |grep Mount -A2

# Remove the profile
k apply --overwrite -f tests/cm-test-00.yml

# After a few minutes Kubernetes detects those profiles are not loaded anymore 
#   and the pods can be deleted
k get pods -w