source $(dirname $0)/env.sh

kubectl ws create tmc --enter --ignore-existing
kubectl ws create demo --enter --ignore-existing

for i in 1 2 3
do
    kubectl kcp workload sync c$i \
        --output-file=.kind/c$i.yaml \
        --syncer-image=$SYNCER_IMAGE \
        --replicas=0 \
        $SYNC_RESOURCES_LIST

    kubectl apply -f .kind/c$i.yaml --kubeconfig $KND
done
