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

RESOURCES_LONG="--resources=deployments.apps --resources=services --resources=persistentvolumeclaims"
RESOURCES_SHORT="--resources=deployments.apps,services,persistentvolumeclaims"

echo "[DEBUG] NAME = $NAME"
echo "[DEBUG] CTX  = $CTX"
echo "[DEBUG] WS   = $WS"

kubectl kcp workload sync $NAME \
    --output-file=$YAML \
    --syncer-image=syncer \
    --feature-gates=KCPLocationAPI=true \
    --replicas=0 \
    $RESOURCES_SHORT
kubectl apply -f $YAML --context $CTX

UUID=$(kubectl get synctarget $NAME -o jsonpath="{.metadata.uid}")
NAMESPACE=$(kubectl get ns -o name --context $CTX | grep "kcp-syncer-$NAME-" | tail -n 1 | cut -d'/' -f2-)

echo "[DEBUG] UUID      = $UUID"
echo "[DEBUG] NAMESPACE = $NAMESPACE"

NAMESPACE="$NAMESPACE" \
  syncer \
  --dns localhost \
  --from-kubeconfig=$KUBECONFIG \
  --from-cluster=$WS \
  --from-context=system:admin \
  --to-kubeconfig=$KUBECONFIG \
  --to-context=$CTX \
  --sync-target-name=$NAME \
  --sync-target-uid=$UUID \
  --feature-gates=KCPLocationAPI=true \
  $RESOURCES_LONG
