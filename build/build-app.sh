#!/bin/bash
set -e

cd .    # to avoid Make "getcwd: No such file or directory" error
source ./config/config

# K8S Deployment
sed "s/APP_VERSION/${APP_VERSION}/" ./deploy/evil_deployment_template.yaml > ./deploy/evil_deployment.yaml
sed -i "s/#SERVER_PORT#/${SERVER_PORT}/" ./deploy/evil_deployment.yaml

# Dockerfile
sed -i "s/^EXPOSE .*/EXPOSE ${SERVER_PORT}/" Dockerfile.in
sed -i "s/^ENV SERVER_PORT .*/ENV SERVER_PORT = ${SERVER_PORT}/" Dockerfile.in

make
make test
make container
make push
