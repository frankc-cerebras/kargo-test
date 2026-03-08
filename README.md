# kargo-test

This tests specific applications of Kargo.

## Instructions

1. Install Demo Kargo/Argo after Docker Desktop's Kubernetes support is enabled: `curl -L https://raw.githubusercontent.com/akuity/kargo/main/hack/quickstart/install.sh | sh`
  1. You may have to reset Argo password:
```bash
BCRYPT_HASH=$(argocd account bcrypt --password "adminadmin")
kubectl -n argocd patch secret argocd-secret \
--type='merge' \
-p='{"stringData": {
"admin.password": "'$BCRYPT_HASH'",
"admin.passwordMtime": "'$(date -u +'%Y-%m-%dT%H:%M:%SZ')'"
}}'
```
1. Fork this repository
1. Get a GitHub Personal Access Token
1. Set environment variables:
```bash
export GITOPS_REPO_URL=https://github.com/<your github username>/kargo-demo
export GITHUB_USERNAME=<your github username>
export GITHUB_PAT=<your personal access token>
```
1. Deploy the base applications
```bash
kubectl apply -f k8s/rendered/dev/manifest.yaml
kubectl apply -f k8s/rendered/test/manifest.yaml
kubectl apply -f k8s/rendered/prod/manifest.yaml
```
1. Deploy the Argo configurations
```bash
kubectl apply -f k8s/argo/dev/application.yaml
kubectl apply -f k8s/argo/test/application.yaml
kubectl apply -f k8s/argo/prod/application.yaml
```