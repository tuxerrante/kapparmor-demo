#!/bin/bash
#
# This is intended to run a real Kubernetes cluster
############################################################

export SERVICE_PORT=8090

############################################################
echo "---- Nodes" && kubectl get nodes
echo 

echo "---- Check for Kapparmor helm chart"
# echo "Kapparmor chart not present, installing it in the default namespace"
helm repo add tuxerrante https://tuxerrante.github.io/kapparmor
helm upgrade kapparmor --install --atomic --timeout 10s --set image.tag=0.1.4_dev tuxerrante/kapparmor

# echo 
# echo "---- Deployments"  && kubectl get -A deployment
echo 
echo "---- Daemonsets"  && kubectl get -A daemonset
echo 
echo "---- Services"  && kubectl get -A service
echo 
############################################################
# Deploy the souspicious service
kubectl delete deployment evil
kubectl apply -f deploy/evil_deployment.yaml

echo "> Creating service "
kubectl create service clusterip --tcp=$SERVICE_PORT:$SERVICE_PORT --insecure-skip-tls-verify=true evil

echo "> Creating ingress "
kubectl apply -f ./hack/evil-ingress.yaml
# kubectl create ingress evil --default-backend evil:$SERVICE_PORT

############################################################
# Verify the logs
echo 
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

############################################################
# Now follow instructions in demo.md
#
