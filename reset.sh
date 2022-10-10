source "$(dirname $0)/env.sh"

rm -rf .kcp/

podman rm -f kind-control-plane
kind create cluster
