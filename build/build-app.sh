#!/bin/bash
cd .    # to avoid Make "getcwd: No such file or directory" error
. ./config/config

sed "s/APP_VERSION/${APP_VERSION}/" ./deploy/evil_service_template.yaml > ./deploy/evil_service.yaml
sed -i "s/^VERSION ?=.*/VERSION ?= $APP_VERSION/" Makefile

make
make test
make container
make push
