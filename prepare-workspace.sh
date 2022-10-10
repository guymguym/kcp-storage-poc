source "$(dirname $0)/env.sh"
kind export kubeconfig
kubectl config use-context root
kubectl ws use root
kubectl ws create tmc --enter --ignore-existing
kubectl ws create demo --enter --ignore-existing

kubectl ws use root:tmc:demo
