#!/bin/bash
# PROJECT=p-ingress-tutorial
# CLUSTER=nginx-tutorial
# ZONE=us-central1-c
# RELEASE=tutorial
# LB_STATIC_IP=34.71.238.129
# NGINX_CHART_TARGET="3.23.0"

KUBE_CONTEXT=gke_${PROJECT}_${ZONE}_${CLUSTER}
kubectl config use-context $KUBE_CONTEXT

CHART_NAME="ingress-nginx/ingress-nginx"
NAMESPACE=default
VALUES_FILE=ingress-nginx.yaml

generateValues() {
   cat << EOF > "${VALUES_FILE}"
# Override values for ingress-nginx

controller:
 ## Use host ports 80 and 443
 hostPort:
   enabled: true
 kind: DaemonSet
 service:
   ## Set static IP for LoadBalancer
   loadBalancerIP: ${LB_STATIC_IP}
   externalTrafficPolicy: Cluster
 stats:
   enabled: true
 metrics:
   enabled: true
 admissionWebhooks:
   enabled: false
defaultBackend:
 enabled: true
EOF
}

generateValues
echo
helm3 upgrade --install ${RELEASE}  --kube-context $KUBE_CONTEXT -n ${NAMESPACE} ${CHART_NAME} --version ${NGINX_CHART_TARGET} -f ${VALUES_FILE}
echo
kubectl -n ${NAMESPACE} get all
echo
kubectl wait --namespace $NAMESPACE \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s
echo
kubectl --namespace $NAMESPACE get services -o wide -w ${RELEASE}-ingress-nginx-controller
