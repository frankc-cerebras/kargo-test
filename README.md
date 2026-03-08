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

Reset the ArgoCD admin password:
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
2. In the following file, update the repository URL to match your fork:
   - `k8s/argo/base/application.yaml`
3. Create a Kargo `secrets.yaml` file by copying the provided `secrets-template.yaml` (ensure you have populated it with your GitHub token).

### 4. Deploy Base Services
Deploy the initial manifest files to simulate an existing environment prior to Kargo management:
```bash
kubectl apply -f k8s/rendered/dev/manifest.yaml
kubectl apply -f k8s/rendered/test/manifest.yaml
kubectl apply -f k8s/rendered/prod-dc1/manifest.yaml
kubectl apply -f k8s/rendered/prod-dc2/manifest.yaml
```

Verify the services are running. By default, they use `nginx` version `1.25` (as shown in the `Server` header in the response):
- **Dev**: `curl -v http://localhost:32050`
- **Test**: `curl -v http://localhost:32051`
- **Prod DC1**: `curl -v http://localhost:32052`
- **Prod DC2**: `curl -v http://localhost:32053`

![curl request to dev environment](images/initial-state-curl.png?raw=true "curl request to dev environment")

### 5. Deploy Argo CD and Kargo Configurations
Apply the Argo CD application configurations:
```bash
kubectl apply -k k8s/argo/dev
kubectl apply -k k8s/argo/test
kubectl apply -k k8s/argo/prod-dc1
kubectl apply -k k8s/argo/prod-dc2
```

You can visit Argo CD at http://localhost:31080/ to view the state of the applications.

![Argo CD initial state](images/argo-initial-state.png?raw=true "Argo CD initial state")

You may want to synchronize the Argo CD cluster in the GUI at this point, so that Argo can add its annotations. You can do so by clicking on the Sync Apps button on the Applications page.

![Argo CD initial sync](images/argo-initial-sync.png?raw=true "Argo CD initial sync")

Deploy the Kargo warehouse and stages, along with your created secrets:
```bash
kubectl apply -f k8s/kargo/kargo.yaml
kubectl apply -f k8s/kargo/secrets.yaml
```

You can visit Kargo at http://localhost:31081/ to view the state of the Kargo deployment pipeline.

![Kargo initial state](images/kargo-initial-state.png?raw=true "Kargo initial state")

## Deployment Workflow

Once configured, Kargo will automatically detect new upstream versions (e.g., of `nginx:stable`) and create a new **Freight**.

**Promote to Dev**: In the Kargo UI, drag the newly created Freight onto the `dev` stage to initiate the deployment. 

*Note: If GitHub Actions are enabled on your fork (it usually is be for public repositories), the rendering and merging process will be performed automatically.*

*Note: You can speed up Kargo's synchronization with GitHub by clicking the refresh button to force Kargo to pull the latest GitHub status once the PR has been merged successfully.*

![Kargo drag freight to dev](images/kargo-drag-to-dev.png?raw=true "Kargo drag freight to dev")

![Kargo promote screen](images/kargo-promote-screen.png?raw=true "Kargo promote screen")

![Kargo promotion in progress](images/kargo-promote-in-progress.png?raw=true "Kargo promotion in progress")

![Github pull request completed](images/github-pr-merged.png?raw=true "GitHub pull request automatically completed")

![Kargo promotion succeeded](images/kargo-promote-success.png?raw=true "Kargo promotion succeeded")

![Kargo state after dev deployment succeeded](images/kargo-state-after-dev.png?raw=true "Kargo state after dev deployment")

**Verify Deployment**: After the Argo CD sync completes, test the Dev endpoint again:

```bash
curl -v http://localhost:32050
```

The service should now be updated to the latest stable version of `nginx` (e.g., `1.28`).

![curl request to dev environment after deployment](images/deployed-state-curl.png?raw=true "curl request to dev environment after deployment")

**Promote Further**: Repeat the promotion process for the `test`, `prod-dc1`, and `prod-dc2` environments as desired.
