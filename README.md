Make clone (or use your existing clone) of the kcp repo:

```
git clone github.com/kcp-dev/kcp
cd kcp
```


Clone this kcp-storage-poc repo under the kcp repo:

```
git clone github.com/guymguym/kcp-storage-poc
```


Build kcp binaries from source:

```
./kcp-storage-poc/build.sh
```


Run kcp server:

```
./kcp-storage-poc/run-kcp.sh
```


Prepare the workspace:

```
./kcp-storage-poc/prepare-workspace.sh
```


Run a syncer for targets with name a1, a2 ...:

```
./kcp-storage-poc/run-syncer.sh a1
./kcp-storage-poc/run-syncer.sh a2
```


Deploy app:

```
kubectl create ns app1 
kubectl apply -f ./kcp-storage-poc/app1/ -n app1
```


Check 
```
kubectl --context kind-kind get pod,pvc,svc -n kcp-2k7dq74b07cp
```


To be continued.

