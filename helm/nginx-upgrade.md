# ENV
```
export PROJECT=p-ingress-tutorial
export CLUSTER=nginx-tutorial
export ZONE=us-central1-c
export RELEASE=tutorial
export NGINX_NAMESPACE=default
export KUBE_CONTEXT=gke_${PROJECT}_${ZONE}_${CLUSTER}
```

# K8s context
export KUBE_CONTEXT=gke_${PROJECT}_${ZONE}_${CLUSTER}
kubectl config current-context
kubectl config use-context $KUBE_CONTEXT

# Detect NGINX controller Version
```
POD_NAME=$(kubectl get pods -n $NGINX_NAMESPACE -l app=nginx-ingress -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it $POD_NAME -n $NGINX_NAMESPACE -- /nginx-ingress-controller --version
```

# Check config v2 & v3
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

# Init Helm v3
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
helm3 upgrade --reuse-values $RELEASE ingress-nginx/ingress-nginx --kube-context $KUBE_CONTEXT \
  --set controller.admissionWebhooks.enabled=false \
  --set controller.admissionWebhooks.patch.enabled=false \
  --set defaultBackend.enabled=true

kubectl wait --namespace $NGINX_NAMESPACE \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s
```
