FROM gcr.io/google.com/cloudsdktool/cloud-sdk:latest AS cloud-sdk
RUN apt-get update
RUN apt-get install -y curl wget gnupg

# Helm v3
RUN curl https://baltocdn.com/helm/signing.asc | apt-key add -
RUN apt-get install apt-transport-https --yes
RUN echo "deb https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
RUN apt-get update
RUN apt-get install helm --yes
RUN ln -s /usr/bin/helm /usr/bin/helm3
# supported helm v2 APT package is 2.16.7-3 through 2.17.0-1

# Helm v2
RUN curl -s https://get.helm.sh/helm-v2.14.3-linux-amd64.tar.gz | tar xzf -
RUN mv linux-amd64/helm linux-amd64/tiller /usr/local/bin/
RUN ln -s /usr/local/bin/helm /usr/bin/helm2

# GCLOUD
# RUN export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"
# RUN echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
# RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
# RUN apt-get update && apt-get install google-cloud-sdk
RUN curl https://sdk.cloud.google.com | bash
# RUN gcloud init --console-only

# Extra utils
RUN apt-get install -y vim nano

# USER
# ENV HOME /home/user
# RUN mkdir -p $HOME && useradd user -d $HOME && chown -R user:user $HOME
# WORKDIR $HOME
# USER user



