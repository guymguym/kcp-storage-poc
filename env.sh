KCP=".kcp/admin.kubeconfig"
KND=".kind/kubeconfig"
KWS="root:tmc:demo"

FEATURE_GATES="--feature-gates=KCPLocationAPI=true"

SYNC_RESOURCES="--resources=deployments.apps --resources=services --resources=persistentvolumeclaims"
SYNC_RESOURCES_LIST="--resources=deployments.apps,services,persistentvolumeclaims"
SYNC_TARGET_NAME="cluster1"

SYNCER_IMAGE="kind.local/syncer"

export KUBECONFIG=$KCP
export PATH="${PATH}:${PWD}/bin"

# kubectl ws use $KWS
