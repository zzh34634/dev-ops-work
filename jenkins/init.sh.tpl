#!/bin/bash  

# helm

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# install ingress-nginx
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace --wait --version "4.7.2"

# install jenkins
helm repo add jenkins https://charts.jenkins.io
helm repo update

# create ns
kubectl create ns jenkins

# service account for kubernetes secret provider
kubectl apply -f /tmp/jenkins-service-account.yaml -n jenkins

# jenkins github personal access token
kubectl apply -f /tmp/github-personal-token.yaml -n jenkins

# jenkins github server(system) pat secret
kubectl apply -f /tmp/github-pat-secret-text.yaml -n jenkins

# install jenkins helm
helm upgrade -i jenkins jenkins/jenkins -n jenkins --create-namespace -f /tmp/jenkins-values.yaml --version "4.6.1"

# install argocd
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm upgrade --install argocd argo/argo-cd -n argocd --create-namespace -f /tmp/argocd-values.yaml

# github PAT secret, for PR check
kubectl create secret generic github-token \
  --from-literal=token=${github_personal_token} -n argocd

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f /tmp/argocd-dashboard-ingress.yaml -n argocd

helm upgrade -i crossplane \
--namespace crossplane-system \
--create-namespace crossplane-stable/crossplane \
--version "1.14.0" \
--wait

kubectl apply -f /tmp/tf-provider.yaml -n crossplane-system

kubectl apply -f /tmp/argocd-applicationset.yaml -n argocd