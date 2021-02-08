# Preparation
*Warning:*
  Avoid performing operations with Helm v3 until data migration is complete and you are satisfied that it is working as expected. Otherwise, Helm v3 data might be overwritten. The operations to avoid are chart install, adding repositories, plugin install etc.

https://github.com/helm/helm-2to3

# Set ENV and K8s context
```
export PROJECT=p-ingress-tutorial
export CLUSTER=nginx-tutorial
export ZONE=us-central1-c
export RELEASE=tutorial
export APP=nginx-ingress

export KUBE_CONTEXT=gke_${PROJECT}_${ZONE}_${CLUSTER}
kubectl config current-context
kubectl config use-context $KUBE_CONTEXT
```

# Run Helm and Chart Backups
```
helm3 ls
helm2 ls
helm2 get $RELEASE >| $RELEASE.chart.v2.yaml
helm2 get cert-manager >| cert-manager.chart.v2.yaml
tar -czvf helm.config.tgz ~/.helm
```

# Migrate Helm configs & data
```
export HELM_V2_HOME=$PWD/.helm
export HELM_V3_CONFIG=$PWD/.config/helm
export HELM_V3_DATA=$PWD/.local/share/helm

helm3 plugin install https://github.com/helm/helm-2to3.git
helm3 2to3 move config --dry-run
helm3 2to3 move config
helm3 repo remove local
helm3 repo update
```

# Migrate Charts
```
helm3 2to3 convert $RELEASE --dry-run --release-versions-max 3 --kube-context $KUBE_CONTEXT
helm3 2to3 convert $RELEASE --release-versions-max 3 --kube-context $KUBE_CONTEXT
```

# Final Clean-up
*Warning:*
  The full cleanup command will remove the Helm v2 Configuration, Release Data and Tiller Deployment. It cleans up all releases managed by Helm v2. It will not be possible to restore them if you haven't made a backup of the releases. Helm v2 will not be usable afterwards. Full cleanup should only be run once all migration (clusters and Tiller instances) for a Helm v2 client instance is complete. Helm v2 may also become unusable depending on cleanup of individual parts.

*Note:*
  Before performing a full or release data clean, remove any Helm v2 releases which have not been migrated to Helm v3 and are unwanted

```
helm3 2to3 cleanup
```
