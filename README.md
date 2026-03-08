# Kargo Test Repository

This repository contains a demonstration and testing environment for [Kargo](https://kargo.akuity.io/), specifically focusing on application delivery workflows.

## Prerequisites

Before getting started, ensure you have the following installed:
- Docker Desktop with Kubernetes support enabled.
- A GitHub Personal Access Token.
- `curl` and `kubectl` command-line tools.

## Setup Instructions

### 1. Install Kargo and Argo CD
Install the demo Kargo and Argo CD environments using the official quickstart script:
```bash
curl -L https://raw.githubusercontent.com/akuity/kargo/main/hack/quickstart/install.sh | sh
```

*Note: You will likely need to reset the admin password to ArgoCD.*
```bash
BCRYPT_HASH=$(argocd account bcrypt --password "adminadmin")
kubectl -n argocd patch secret argocd-secret \
  --type='merge' \
  -p='{"stringData": {
    "admin.password": "'$BCRYPT_HASH'",
    "admin.passwordMtime": "'$(date -u +'%Y-%m-%dT%H:%M:%SZ')'"
  }}'
```

### 2. Verify Installation
Ensure both services are accessible:
- **Argo CD**: http://localhost:31080/ (Username: `admin`, Password: `adminadmin`)
- **Kargo**: http://localhost:31081/ (Password: `admin` by default)

### 3. Repository Configuration
1. Fork this repository to your own GitHub account.
2. In the following files, update the repository URLs to match your fork:
   - `k8s/argo/dev/application.yaml`
   - `k8s/argo/test/application.yaml`
   - `k8s/argo/prod/application.yaml`
3. Create a Kargo `secrets.yaml` file by copying the provided `secrets-template.yaml` (ensure you have populated it with your GitHub token).

### 4. Deploy Base Services
Deploy the initial manifest files to simulate an existing environment prior to Kargo management:
```bash
kubectl apply -f k8s/rendered/dev/manifest.yaml
kubectl apply -f k8s/rendered/test/manifest.yaml
kubectl apply -f k8s/rendered/prod/manifest.yaml
```

Verify the services are running. By default, they use `nginx` version `1.25`:
- **Dev**: `curl -v http://localhost:32050`
- **Test**: `curl -v http://localhost:32051`
- **Prod**: `curl -v http://localhost:32052`

### 5. Deploy Argo CD and Kargo Configurations
Apply the Argo CD application configurations:
```bash
kubectl apply -f k8s/argo/dev/application.yaml
kubectl apply -f k8s/argo/test/application.yaml
kubectl apply -f k8s/argo/prod/application.yaml
```

Deploy the Kargo warehouse and stages, along with your created secrets:
```bash
kubectl apply -f k8s/kargo/kargo.yaml
kubectl apply -f k8s/kargo/secrets.yaml
```

## Deployment Workflow

Once configured, Kargo will automatically detect new upstream versions (e.g., of `nginx`) and create a new **Freight**.

1. **Promote to Dev**: In the Kargo UI, drag the newly created Freight onto the `dev` stage to initiate the deployment. *(Note: If GitHub Actions are enabled on your fork (it usually is be for public repositories), the rendering and merging process will be performed automatically).*
2. **Verify Deployment**: After the Argo CD sync completes, test the Dev endpoint again:
   ```bash
   curl -v http://localhost:32050
   ```
   The service should now be updated to the latest stable version of `nginx` (e.g., `1.28`).
3. **Promote Further**: Repeat the promotion process for the `test` and `prod` environments as desired.
