#!/bin/bash
# TODO: replace windows ending lines
set -e

cd .    # to avoid Make "getcwd: No such file or directory" error

sed -i 's/\r$//' ./deploy/evil_deployment_template.yaml
sed -i 's/\r$//' ./deploy/evil_deployment_template_profiled.yaml
sed -i 's/\r$//' ./config/config

source ./config/config

# Create K8S Deployments
sed "s/APP_VERSION/${APP_VERSION}/" ./deploy/evil_deployment_template.yaml          > ./deploy/evil_deployment.yaml
sed "s/APP_VERSION/${APP_VERSION}/" ./deploy/evil_deployment_template_profiled.yaml > ./deploy/evil_deployment_profiled.yaml

# We need some extra parameter to replace strings between double quotes
sed -i 's/containerPort: #SERVER_PORT#/containerPort: '"${SERVER_PORT}"'/'  ./deploy/evil_deployment.yaml
sed -i 's/containerPort: #SERVER_PORT#/containerPort: '"${SERVER_PORT}"'/'  ./deploy/evil_deployment_profiled.yaml

sed -i.bkp -e 's/value: #SERVER_PORT#/value: "'"${SERVER_PORT}"'"/g'  ./deploy/evil_deployment.yaml
sed -i.bkp -e 's/value: #SERVER_PORT#/value: "'"${SERVER_PORT}"'"/g'  ./deploy/evil_deployment_profiled.yaml

# Remove Windows line endings
sed -i 's/\r$//' ./deploy/evil_deployment.yaml
sed -i 's/\r$//' ./deploy/evil_deployment_profiled.yaml

# Dockerfile
sed -i 's/\r$//' Dockerfile.in
sed "s/^EXPOSE .*/EXPOSE ${SERVER_PORT}/" Dockerfile.in > Dockerfile
sed -i "s/^ENV SERVER_PORT .*/ENV SERVER_PORT = ${SERVER_PORT}/" Dockerfile

# Clean old images
echo "> Removing old and dangling old images..."
# docker rmi "$(docker images --filter "reference=teamsis2022/evil-nginx" -q --no-trunc )" 

make
make test
make container
make push
