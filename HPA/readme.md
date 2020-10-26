# Reference documentation
- https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/#autoscaling-on-multiple-metrics-and-custom-metrics
- https://cloud.google.com/kubernetes-engine/docs/tutorials/autoscaling-metrics
- https://cloud.google.com/monitoring/api/metrics_kubernetes#kubernetes-nginx
- https://medium.com/uptime-99/kubernetes-hpa-autoscaling-with-custom-and-external-metrics-da7f41ff7846 (outdated)
- https://github.com/nginxinc/nginx-prometheus-exporter#exported-metrics
- https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.17.md

# Deploy demo php-app
```
kubectl apply -f https://k8s.io/examples/application/php-apache.yaml
```

# Deploy Ingress Controller
```
helm install nginx-ingress stable/nginx-ingress
```

# Create Ingress
```
INGRESS_HOST="$(kubectl --namespace default get services nginx-ingress-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
echo $INGRESS_HOST
```

# Enable ingress
```
export INGRESS_HOST
envsubst < php-app-ingress-nginx.tmpl >| php-app-ingress-nginx.yaml
kubectl apply -f php-app-ingress-nginx.yaml
kubectl get ingress php-apache
```

# Enable HPA (CPU/RPS)
```
kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10
kubectl get hpa
kubectl delete hpa php-apache
```

# Patch Nginx-Ingress with Prometheus-to-SD exporter
```
kubectl get deployment nginx-ingress-controller -o yaml > nginx-ingress-controller.yaml
kubectl patch deployment nginx-ingress-controller --patch "$(cat nginx-ingress-patch.yaml)"
kubectl get deployment nginx-ingress-controller -o yaml > nginx-ingress-controller-sd.yaml
```

# Custom metrics per Resource Type
- https_lb_rule (L7)
  - `loadbalancing.googleapis.com/https/backend_request_count`
- tcp_lb_rule / internal_tcp_lb_rule (L3)
  - `loadbalancing.googleapis.com/l3/external/ingress_packets_count`
- k8s_container (ALPHA)
  - `kubernetes.io/nginx/http_requests_total`
- k8s_container (N/A)
  - `external.googleapis.com/prometheus/http_requests_total`
- custom
  - `custom.googleapis.com/nginx_ingress_controller_nginx_process_requests_total`     (rate)
  - `custom.googleapis.com/nginx_ingress_controller_nginx_process_connections_total`  (rate)
  - `custom.googleapis.com/nginx_ingress_controller_nginx_process_connections`        (accumulated)

# Check Nginx metric exported
```
kubectl get --raw "/apis/external.metrics.k8s.io/v1beta1/namespaces/default/custom.googleapis.com|nginx_ingress_controller_nginx_process_requests_total" | jq
```

# Enable HPA (Nginx RPS/Connections)
```
kubectl delete hpa php-apache
kubectl apply -f php-app-hpa-nginx.yaml
```

# Increase load
```
ab -n 10000 -c 100 http://tcp.$INGRESS_HOST.nip.io/php
```
