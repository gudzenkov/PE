# Migration Path for each Product Cluster
1. [Helm v2->v3 Migrate](helm-upgrade.md)
2. A. K8s Upgrade v1.16
3. A. [Nginx-ingress Chart Upgrade v1.17 -> Ingress-nginx v3.x](nginx-upgrade.md)
4. B. [Nginx-ingress Chart Upgrade v1.17 -> Ingress-nginx v2.x](nginx-upgrade.md)
5. K8s Upgrade v1.15 -> v1.16 -> v1.17 - Blue-Green Zero-downtime migration (DNS or GCLB)

# ENV
```
export PROJECT=gke-onprem-lab-281510
export CLUSTER=nginx-dev-cluster
export ZONE=us-central1-c
export RELEASE=tutorial
export APP=nginx-ingress
export KUBE_VERSION=1.15.12-gke.6002
export KUBE_CONTEXT=gke_${PROJECT}_${ZONE}_${CLUSTER}
export HELM_VERSION=v2.14.3
export HELM_TARGET=v3.5.2
export NGINX_NAMESPACE=default
export NGINX_CHART_VERSION=1.17.1
export NGINX_CHART_TARGET=3.23.0
export LB_STATIC_IP=34.71.238.129

# Component versions
NGINX_RELEASE=0.25.1
NGINX_VERSION=openresty/1.15.8.1
NGINX_IMAGE=quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.25.1
NGINX_TARGET_CHART=ingress-nginx-3.23.0
NGINX_TARGET_RELEASE=0.44.0
NGINX_TARGET_IMAGE=k8s.gcr.io/ingress-nginx/controller:v0.44.0
NGINX_CHART_MANIFEST=https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.44.0/deploy/static/provider/cloud/deploy.yaml
```
# [Dockerized env setup for dry-run](env-prep.md)
