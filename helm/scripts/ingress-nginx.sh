#!/bin/bash

CHART_NAME="center/kubernetes-ingress-nginx/ingress-nginx"
CHART_VERSION="2.11.1"
RELEASE=nginx-ingress
NAMESPACE=nginx-ingress
VALUES_FILE=ingress-nginx.yaml
LB_STATIC_IP=35.197.192.35

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
   externalTrafficPolicy: Local
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
helm3 upgrade --install ${RELEASE} -n ${NAMESPACE} ${CHART_NAME} --version ${CHART_VERSION} -f ${VALUES_FILE}
echo
kubectl -n ${NAMESPACE} get all
