source $(dirname $0)/env.sh

rm -rf .kcp/ .kind/
podman rm -f kind-control-plane
kind create cluster --kubeconfig $KC1
kind export kubeconfig --kubeconfig $KC1
