source $(dirname $0)/env.sh

kubectl ws use $KWS
SYNC_TARGET_UID=$(kubectl get synctarget $SYNC_TARGET_NAME -o jsonpath="{.metadata.uid}")
echo "[DEBUG] SYNC_TARGET_UID=$SYNC_TARGET_UID"

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
