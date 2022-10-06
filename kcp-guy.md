```bash

# env
KCP=".kcp/admin.kubeconfig"
KC1=".kcp-c1/kubeconfig"
KWS="root:tmc:demo"
FEATURE_GATES="--feature-gates=KCPLocationAPI=true"
SYNC_TARGET_NAME="cluster1"
SYNC_RESOURCES="--resources=deployments.apps,services,persistentvolumeclaims"
SYNCER_IMAGE="kind.local/syncer"
export KUBECONFIG=$KCP
export PATH="${PATH}:${PWD}/bin"

# kind
kind create cluster --kubeconfig $KC1
kind export kubeconfig --kubeconfig $KC1

# build
go mod tidy
go mod vendor
echo '*' >> vendor/.gitignore
IGNORE_GO_VERSION=1 make

# don't have to build a syncer image when running the binary directly
# SYNCER_IMAGE=$(KUBECONFIG=$KC1 KO_DOCKER_REPO=kind.local ko build --platform=linux/arm64 ./cmd/syncer)

# kcp
kcp start \
  $FEATURE_GATES \
  --token-auth-file=test/e2e/framework/auth-tokens.csv

# workspace
kubectl ws create tmc --enter --ignore-existing
kubectl ws create demo --enter --ignore-existing
kubectl ws use $KWS

# synctarget
kubectl kcp workload sync $SYNC_TARGET_NAME \
  --output-file=.kcp-c1/syncer.yaml \
  --syncer-image=$SYNCER_IMAGE \
  --replicas=0 \
  $SYNC_RESOURCES

kubectl apply -f .kcp-c1/syncer.yaml --kubeconfig $KC1
SYNC_TARGET_UID=$(kubectl get synctarget $SYNC_TARGET_NAME -o jsonpath="{.metadata.uid}")
echo $SYNC_TARGET_UID

# syncer
syncer \
  --from-kubeconfig=$KCP \
  --from-context=system:admin \
  --from-cluster=$KWS \
  --to-kubeconfig=$KC1 \
  --sync-target-name=$SYNC_TARGET_NAME \
  --sync-target-uid=$SYNC_TARGET_UID \
  $FEATURE_GATES \
  $SYNC_RESOURCES

# deploy app
kubectl create ns app1 
kubectl apply -f app1.yaml -n app1
```


# first time only setup

```bash
brew install podman docker kind ko jq kubernetes-cli
podman machine init --cpus 6 --memory 6144
podman machine ssh bash -c 'cat << EOF > /etc/systemd/system/user@.service.d/delegate.conf
[Service]
Delegate=yes
EOF'
podman machine ssh sudo bash -c 'cat << EOF > /etc/modules-load.d/iptables.conf
ip6_tables
ip6table_nat
ip_tables
iptable_nat
EOF'
podman machine ssh systemctl daemon-reload
podman machine ssh modprobe -v ip6_tables
podman machine ssh lsmod | grep ip6
podman machine start
```

# OLD - kubeconfig contexts

```bash
kubectl config use-context root
kubectl ws use root:guymguym:kcp-storage
kubectl ws create-context kcp-storage --overwrite
kubectl config set-context kcp-storage --namespace app1
kubectl config use-context kcp-storage
kubectl config get-contexts
kind export kubeconfig --name cluster1
```


# OLD - deploy syncer to cluster

```bash
SYNCER_IMAGE="ko.local/github.com/kcp-dev/kcp/cmd/syncer"
ko build --local -t latest --tag-only --preserve-import-paths --platform=linux/arm64 ./cmd/syncer
kubectl config use-context kcp-storage
kubectl kcp workload sync cluster1 \
  --syncer-image $SYNCER_IMAGE \
  --resources=deployments.apps,services,persistentvolumeclaims \
  --output-file syncer-cluster1.yaml
kind create cluster --name cluster1
kind load docker-image $SYNCER_IMAGE --name cluster1
kubectl --context kind-cluster1 delete -f syncer-cluster1.yaml
kubectl --context kind-cluster1 apply -f syncer-cluster1.yaml
```
