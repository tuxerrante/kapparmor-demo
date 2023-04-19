#!/bin/bash
#
# First setup the cluster: hack/setup-kind.sh
# Check that the ingress and the ingress controller are fine
############################################################

# MANDATORY: Setup kubectl connections
alias kubectl='microk8s kubectl'
alias k='microk8s kubectl'
kubectl config use-context microk8s
############################################################
export SERVICE_PORT=8090

############################################################
echo "---- Nodes" && kubectl get nodes
echo "_________________"

echo "---- Check for Kapparmor helm chart"
# echo "Kapparmor chart not present, installing it in the default namespace"
helm repo add tuxerrante https://tuxerrante.github.io/kapparmor
helm upgrade kapparmor --install --atomic --timeout 10s --set image.tag=v0.1.2 tuxerrante/kapparmor

# echo "_________________"
# echo "---- Deployments"  && kubectl get -A deployment
echo "_________________"
echo "---- Daemonsets"  && kubectl get -A daemonset
echo "_________________"
echo "---- Services"  && kubectl get -A service
echo "_________________"
############################################################
# Deploy the souspicious service
# kubectl create deployment evil --image teamsis2022/evil-nginx:1.0.0 --replicas 1 --port=${SERVICE_PORT}
kubectl delete deployment evil
kubectl apply -f deploy/evil_deployment.yaml
kubectl create service clusterip --tcp=$SERVICE_PORT:$SERVICE_PORT --insecure-skip-tls-verify=true evil
kubectl get svc evil
############################################################
# Verify the logs
echo "_________________"
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
