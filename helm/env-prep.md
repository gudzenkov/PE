# ENV
```
export PROJECT=p-ingress-tutorial
export CLUSTER=nginx-tutorial
export ZONE=us-central1-c
export RELEASE=tutorial
export APP=nginx-ingress
export HELM_VERSION=v2.14.3
export NGINX_CHART=nginx-ingress-1.17.1
export NGINX_IMAGE=quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.25.1
```

# GCP CloudSDK init and auth
https://cloud.google.com/sdk/docs/downloads-docker#debian-based_images
```
docker pull gcr.io/google.com/cloudsdktool/cloud-sdk:latest
docker tag gcr.io/google.com/cloudsdktool/cloud-sdk:latest gcloud:latest
docker run gcloud:latest gcloud version
docker run -ti --name gcloud-config gcloud:latest gcloud auth login
docker run --rm --volumes-from gcloud-config gcloud:latest gcloud compute instances list --project $PROJECT
docker run --rm --volumes-from gcloud-config gcloud:latest gcloud container clusters get-credentials $CLUSTER --zone $ZONE --project $PROJECT
docker run --rm --volumes-from gcloud-config gcloud:latest kubectl cluster-info && kubectl get deployments
```

# Package Helm v2 & v3
```
docker build . -t gcloud:helm
gcloud run --rm --volumes-from gcloud-config -ti --name gcloud-shell  gcloud:helm gcloud compute instances list --project $PROJECT
docker run --rm --volumes-from gcloud-config -ti --name gcloud-shell  gcloud:helm /bin/bash
```

# Clean Tiller init
```
# uninstall existing Tiller version
helm2 reset --force

# Workaround for unsupported Chart repo as of November 13, 2020
# https://helm.sh/blog/new-location-stable-incubator-charts/
# Old Location:https://kubernetes-charts.storage.googleapis.com
# New Location:https://charts.helm.sh/stable
helm2 init --client-only --skip-refresh
#helm repo add legacy https://kubernetes-charts.storage.googleapis.com
helm2 repo rm stable
helm2 repo add stable https://charts.helm.sh/stable

# Install Tiller (broken for older v2.14.3)
# helm2 init --service-account tiller --tiller-image gcr.io/kubernetes-helm/tiller:$HELM_VERSION

# Workaround for discontinued k8s apiVersion (old Charts)
# https://github.com/helm/helm/issues/6374#issuecomment-533427268
helm2 init --service-account tiller --override spec.selector.matchLabels.'name'='tiller',spec.selector.matchLabels.'app'='helm' --output yaml | sed 's@apiVersion: apps/v1@apiVersion: apps/v1@' | kubectl apply -f -
```

# Clean Nginx-ingress
```
# Clean-up
helm2 delete nginx-ingress
helm2 delete ${RELEASE}
helm2 del --purge ${RELEASE}

# Install (broken for older charts due to k8s API change)
# helm install --name ${RELEASE} stable/nginx-ingress --version '1.17.1'

# Workaround for discontinued k8s apiVersion and missing labels (old Charts)
cd root && helm fetch  stable/nginx-ingress --version '1.17.1' --untar
cd nginx-ingress/templates/
sed -i 's|extensions/v1beta1|apps/v1|g' *.yaml

sed -z -i 's/^spec:/spec:\n  selector:\n    matchLabels:\n      app: {{ template "nginx-ingress.name" . }}\n      release: {{ .Release.Name }}\n      component: "{{ .Values.controller.name }}"/' controller-deployment.yaml
sed -z -i 's/^spec:/spec:\n  selector:\n    matchLabels:\n      app: {{ template "nginx-ingress.name" . }}\n      release: {{ .Release.Name }}\n      component: "{{ .Values.defaultBackend.name }}"/' default-backend-deployment.yaml

cd root
helm2 install --name ${RELEASE}  ./nginx-ingress --version '1.17.1'
```
