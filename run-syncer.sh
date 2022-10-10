source "$(dirname $0)/env.sh"

usage() {
  echo "Usage: run-syncer.sh <name>"
  exit 1
}

NAME="$1"
[ -z "$NAME" ] && usage
YAML="${PWD}/.kcp/syncer-${NAME}.yaml"
CTX="kind-kind"
WS="root:tmc:demo"

echo "[DEBUG] NAME = $NAME"
echo "[DEBUG] CTX  = $CTX"
echo "[DEBUG] WS   = $WS"


RESOURCES_LONG="--resources=deployments.apps --resources=services --resources=persistentvolumeclaims"
RESOURCES_SHORT="--resources=deployments.apps,services,persistentvolumeclaims"

# kubectl ws use root
# kubectl ws create tmc --enter --ignore-existing
# kubectl ws create demo --enter --ignore-existing
# kubectl ws create $WS --enter --ignore-existing

kubectl kcp workload sync $NAME \
    --output-file=$YAML \
    --syncer-image=syncer \
    --replicas=0 \
    $RESOURCES_SHORT

kubectl apply -f $YAML --context $CTX

UUID=$(kubectl get synctarget $NAME -o jsonpath="{.metadata.uid}")

echo "[DEBUG] UUID=$UUID"

export NAMESPACE="ns1" # ??

syncer \
  --from-kubeconfig=$KUBECONFIG \
  --from-cluster=$WS \
  --from-context=system:admin \
  --to-kubeconfig=$KUBECONFIG \
  --to-context=$CTX \
  --sync-target-name=$NAME \
  --sync-target-uid=$UUID \
  --feature-gates=KCPLocationAPI=true \
  $RESOURCES_LONG
