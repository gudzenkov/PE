### CloudBuild cache
https://cloud.google.com/build/docs/speeding-up-builds
1. Named builder + --cache-from
Cloud Build also have an internal cache for caching the "cloud builder" image, (the image that you set in the name of your steps)
https://jeanklaas.com/blog/speed-up-builds-cloudbuild/
2. Kaniko
https://cloud.google.com/build/docs/kaniko-cache
5. GCS rsync
```
- name: gcr.io/cloud-builders/gsutil
  args: ['rsync', '-r', 'gs://my-cache-bucket/repository', 'local-cache-dir']
```
4. GCS Cache builders
https://github.com/GoogleCloudPlatform/cloud-builders-community/tree/master/cache
5. GCR Docker Hub mirror
https://cloud.google.com/container-registry/docs/pulling-cached-images
Container Registry caches frequently-accessed public Docker Hub images on mirror.gcr.io
