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
1. Make sure that you can visit Argo at http://localhost:31080/ (username: `admin`, password: `adminadmin`) and Kargo at http://localhost:31081/ (default password: `admin`)
1. Fork this repository
1. Get a GitHub Personal Access Token
1. Deploy the base services (this way we show that we can migrate existing services/deployments)
    ```bash
    kubectl apply -f k8s/rendered/dev/manifest.yaml
    kubectl apply -f k8s/rendered/test/manifest.yaml
    kubectl apply -f k8s/rendered/prod/manifest.yaml
    ```
1. Change the Repo URLs in the follow files and deploy the Argo configurations
    ```bash
    kubectl apply -f k8s/argo/dev/application.yaml
    kubectl apply -f k8s/argo/test/application.yaml
    kubectl apply -f k8s/argo/prod/application.yaml
    ```
1. Create a Kargo `secrets.yaml` from `secrets-template.yaml`
1. Deploy the Kargo configurations
    ```bash
    kubectl apply -f k8s/kargo/secrets.yaml
    kubectl apply -f k8s/kargo/kargo.yaml
    ```
1. Kargo will automatically pick up a new version of nginx and create a new Freight
1. Drag the freight onto `dev` to kick off the deployment process. If Github workflows is enabled in this repository, the rendering and merging is automatic.
