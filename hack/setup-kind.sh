#!/bin/bash
# From WSL2 you need to replace localhost IP to make it work
# MY_HOST_IP=$(dig "${HOSTNAME}".local +short |tail -n 1)
# nmap -p 6442-6446 "${MY_HOST_IP}"
# sed "s/MY_HOST_IP/$MY_HOST_IP/" ./hack/kind-template.yaml > ./hack/kind.yaml
set -e

sed "s/MY_HOST_IP/127.0.0.1/" ./hack/kind-template.yaml > ./hack/kind.yaml

#### Check for Kind presence
if [[ ! $(which kind) ]]; then
  echo "> Install Kind..."
  sudo apt-get install -y jq
  kind_version="$(curl --silent "https://api.github.com/repos/kubernetes-sigs/kind/releases/latest" | jq -r .tag_name)"
  curl -Lo ./kind "https://github.com/kubernetes-sigs/kind/releases/download/${kind_version}/kind-linux-amd64" &&\
   sudo mv kind  /usr/local/bin/kind &&\
   sudo chmod +x /usr/local/bin/kind &&\
   echo "> kind installed in /usr/local/bin/kind"  
fi

if [[ ! $(kind get clusters) = "kind" ]]; then 
  echo "> Create new Kind cluster"
  sudo mkdir -p /etc/apparmor.d/custom
  kind create cluster --config ./hack/kind.yaml >/dev/null
else 
  echo "> The Kind cluster is already up"
fi

# On WSL2 you need to remap port 80 and 443
# kubectl apply -f ./hack/nginx-kind-deploy.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
echo "> Wait 5 min for Nginx controller to start..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s

# It takes some time for the amission controller to get ready before accepting ingresses
sleep 10
kubectl apply -f ./hack/evil-ingress.yaml

kubectl get pod -n ingress-nginx -l "app.kubernetes.io/name"=ingress-nginx
echo
# kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller --follow
echo Check open ports: 
sudo netstat -tlnp
