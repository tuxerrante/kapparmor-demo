#!/bin/bash
# From WSL2 you need to replace localhost IP to make it work
# MY_HOST_IP=$(dig "${HOSTNAME}".local +short |tail -n 1)
# nmap -p 6442-6446 "${MY_HOST_IP}"
# sed "s/MY_HOST_IP/$MY_HOST_IP/" ./hack/kind-template.yaml > ./hack/kind.yaml
set -e

sed "s/MY_HOST_IP/127.0.0.1/" ./hack/kind-template.yaml > ./hack/kind.yaml

#### Check for Kind presence
if [[ ! $(which microk8s) ]]; then
  echo "> Install MicroK8S..."
  sudo snap install microk8s --classic --channel=1.27
  sudo usermod -a -G microk8s $USER
  sudo chown -f -R $USER ~/.kube
  echo "> MicroK8S installed in Snap"
  su - $USER
  microk8s status --wait-ready
fi

cp  $HOME/.kube/config $HOME/.kube/config.BKP.$(date +%Y%m%d%H%M)
microk8s config > $HOME/.kube/config
alias kubectl='microk8s kubectl'
alias k='microk8s kubectl'
kubectl config use-context microk8s
microk8s enable dns hostpath-storage ingress

# It takes some time for the amission controller to get ready before accepting ingresses
kubectl apply -f ./hack/evil-ingress.yaml

kubectl get pod -n ingress -l name=nginx-ingress-microk8s

echo
echo Check open ports: 
# sudo netstat -tlnp
