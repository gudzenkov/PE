#!/bin/bash
PROJECT=p-ingress-tutorial
CLUSTER=nginx-tutorial
ZONE=us-central1-c
KUBE_CONTEXT=gke_${PROJECT}_${ZONE}_${CLUSTER}
kubectl config use-context $KUBE_CONTEXT

CHART_NAME="ingress-nginx/ingress-nginx"
CHART_VERSION="3.23.0"
RELEASE=tutorial
NAMESPACE=default
VALUES_FILE=ingress-nginx.yaml
LB_STATIC_IP=34.66.80.3

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
helm3 upgrade --install ${RELEASE}  --kube-context $KUBE_CONTEXT -n ${NAMESPACE} ${CHART_NAME} --version ${CHART_VERSION} -f ${VALUES_FILE}
echo
kubectl -n ${NAMESPACE} get all
echo
kubectl wait --namespace $NAMESPACE \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s
echo
kubectl --namespace $NAMESPACE get services -o wide -w ${RELEASE}-ingress-nginx-controller
