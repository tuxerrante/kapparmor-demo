#!/bin/bash
set -e

cd .    # to avoid Make "getcwd: No such file or directory" error
source ./config/config

sed "s/APP_VERSION/${APP_VERSION}/" ./deploy/evil_service_template.yaml > ./deploy/evil_service.yaml

sed -i "s/^EXPOSE .*/EXPOSE ${SERVER_PORT}/" Dockerfile.in
sed -i "s/^ENV SERVER_PORT .*/ENV SERVER_PORT = ${SERVER_PORT}/" Dockerfile.in

make
make test
make container
make push
