#!/bin/bash
#
# First setup the cluster: hack/setup-kind.sh
# Check that the ingress and the ingress controller are fine
######
echo "---- Nodes" && kubectl get nodes
echo "------------"

echo "---- Check for Kapparmor helm chart"
# echo "Kapparmor chart not present, installing it in the default namespace"
helm repo add tuxerrante https://tuxerrante.github.io/kapparmor
helm upgrade kapparmor --install --atomic --timeout 120s --set image.tag=v0.1.2 tuxerrante/kapparmor

echo "------------"
echo "---- Deployments"  && kubectl get -A deployment
echo "------------"
echo "---- Daemonsets"  && kubectl get -A daemonset
echo "------------"
echo "---- Services"  && kubectl get -A service
echo "------------"

# Deploy the souspicious service
export SERVICE_PORT=8090

kubectl delete deployment evil
# kubectl create deployment evil --image teamsis2022/evil-nginx:1.0.0 --replicas 1 --port=${SERVICE_PORT}
kubectl apply -f deploy/evil-service.yaml
kubectl create service clusterip --tcp=$SERVICE_PORT:$SERVICE_PORT --insecure-skip-tls-verify=true evil
kubectl get svc evil

# Verify the logs
echo "------------"
kubectl get deployment evil
echo "> Wait for Evil deployment to start..."
kubectl wait --for=condition=ready pod --selector=app=evil --timeout 60s
echo
echo "---- Logs from deployment evil"
kubectl logs deployments/evil
echo
echo "---- Get events"
kubectl get events --sort-by .lastTimestamp
### IN A SECOND TERMINAL
# kubectl proxy --port=${NODE_PORT}
# curl http://localhost:${NODE_PORT}/hello/

###
# Apply apparmor profile

###
# Verify the logs

###
# kind delete cluster
