# Intro
This a demo project to show AppArmor capabilities applied through [Kapparmor](https://github.com/tuxerrante/kapparmor) in a Ubuntu virtual machine.
To simplify it will run on a single node cluster, still it should provide a running Go microservice and an nginx ingress controller.

This could be extended for HA clusters using virtual machines or a real Kubernetes cluster.

This demo can't work on WSL2 since it is only a user-space replica of GNU/Linux, indeed missing some needed kernel space feature (apparmor modules).

# Demo

## Requirements
- Microk8s
- [Docker Engine](https://docs.docker.com/engine/install/ubuntu/#set-up-the-repository) (not from Snap)
- [Kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl) (not from Snap)
- Kubectl
- Helm

## 0. Start microK8s

```bash
./hack/setup-microK8s.sh
```

## 1. Build
From the project root run
```bash
./build/build-app.sh
```

## 2. Deploy
Deploy on MicroK8S
```bash
./deploy/deploy-microk8s.sh
```

Deploy on a real K8S cluster
```bash
./deploy/deploy.sh
```

## 3. Test
After the setup you can **follow the demo in [docs/demo.md](docs/demo.md)**.

# More on Building 

Run `make` or `make build` to compile your app.  This will use docker buildx
(which you need to have installed) to build your app, with the current
directory volume-mounted into place.  This will store incremental state for the
fastest possible build.  Run `make all-build` to build for all architectures.

Run `make container` to build the container image.  It will calculate the image
tag based on the most recent git tag, and whether the repo is "dirty" since
that tag (see `make version`).  Run `make all-container` to build containers
for all supported architectures.

Run `make push` to push the container image to `REGISTRY`.  Run `make all-push`
to push the container images for all architectures.

Run `make manifest-list` to build and push all containers for all
architectures, and then publish a manifest-list for them.

Run `make clean` to clean up.

Run `make help` to get a list of available targets.

## App Testing

Run `make test` and `make lint` to run tests and linters, respectively.  Like
building, this will use docker to execute.

The golangci-lint tool looks for configuration in `.golangci.yaml`.  If that
file is not provided, it will use its own built-in defaults.

## References
- This repo was built using https://github.com/thockin/go-build-template
- https://microK8s.sigs.k8s.io/docs/user/ingress#ingress-nginx
