# Migrate from stable/nginx-ingress to ingress-nginx/ingress-nginx
Latest stable/nginx-ingress is v0.34.1 and it's been de-listed from the Helm Hub on May 13th, 2020

Latest ingress-nginx/ingress-nginx is 3.23.0 on Feb 04, 2021

[Upgrading Nginx With Zero Downtime in Production](https://github.com/kubernetes/ingress-nginx/blob/master/charts/ingress-nginx/README.md#upgrading-with-zero-downtime-in-production)

# Preparation
## ENV
```
export PROJECT=gke-onprem-lab-281510
export CLUSTER=nginx-dev-cluster
export ZONE=us-central1-c
export RELEASE=tutorial
export APP=nginx-ingress
```

## K8s context
```
export KUBE_CONTEXT=gke_${PROJECT}_${ZONE}_${CLUSTER}
kubectl config current-context
kubectl config use-context $KUBE_CONTEXT
```

## Detect NGINX controller Version
```
POD_NAME=$(kubectl get pods -n $NGINX_NAMESPACE -l app=nginx-ingress -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it $POD_NAME -n $NGINX_NAMESPACE -- /nginx-ingress-controller --version
```

## Check config v2 & v3
```
# v2
helm2 status $RELEASE
helm2 inspect stable/nginx-ingress
helm2 get $RELEASE > $RELEASE.chart.v2.yaml
# v3
helm3 status $RELEASE
helm3 show values ingress-nginx/ingress-nginx
helm3 get all $RELEASE > $RELEASE.chart.v3.yaml
```

## Init Helm v3
```
helm3 repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm3 repo update
```

# Migrate from stable/nginx-ingress to ingress-nginx/ingress-nginx
Latest stable/nginx-ingress is v0.34.1 and it's been de-listed from the Helm Hub on May 13th, 2020

Latest ingress-nginx/ingress-nginx is 3.23.0 on Feb 04, 2021
https://rimusz.net/migrating-to-ingress-nginx
https://github.com/kubernetes/ingress-nginx/blob/master/charts/ingress-nginx/README.md#migrating-from-stablenginx-ingress

# Upgrading NGINX controller using Helm
https://kubernetes.github.io/ingress-nginx/deploy/upgrade/
```
# classical upgrade is broken due to large portion of new chart changed
# helm3 upgrade --reuse-values $RELEASE ingress-nginx/ingress-nginx --kube-context $KUBE_CONTEXT
# requires default values override:
# ./scripts/ingress-nginx.sh
# Error: UPGRADE FAILED: chart requires kubeVersion: >=1.16.0-0 which is incompatible with Kubernetes v1.15.12-gke.6002

# Workaround for K8s v1.16
# TBD

# Wait for the Controller and Service to come up
kubectl wait --namespace $NGINX_NAMESPACE \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s
```
