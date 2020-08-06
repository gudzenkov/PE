# Install nginx-ingress
helm install nginx-ingress stable/nginx-ingress --set rbac.create=true --set controller.publishService.enabled=true
kubectl --namespace default get services -o wide -w nginx-ingress-controller
INGRESS_HOST="$(kubectl --namespace default get services nginx-ingress-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
echo $INGRESS_HOST

# Install hello-app
kubectl create deployment hello-app --image=gcr.io/google-samples/hello-app:1.0
kubectl expose deployment hello-app --port=8080 --target-port=8080

# Enable ingress
export INGRESS_HOST
envsubst < hello-app-ingress-nginx.tmpl >| hello-app-ingress-nginx.yaml
kubectl apply -f hello-app-ingress-nginx.yaml
kubectl get ingress hello-app-nginx

