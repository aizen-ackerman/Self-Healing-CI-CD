# Self-Healing CI/CD Pipeline using GitOps and Kubernetes

This repository is now structured as an actual CLI-driven DevOps project, not just a manual walkthrough.

It contains:

- A Python Flask application
- Docker packaging
- Kubernetes manifests
- Argo CD application definition
- Local automation scripts for Kind + Argo CD bootstrap
- A GitHub Actions workflow for automated CI and image publication
- Failure simulation and Git-based rollback helpers

## Folder Structure

```text
self-healing-cicd-gitops/
├── .github/workflows/ci-cd.yaml
├── .tools/bin/
├── app/
│   ├── app.py
│   └── requirements.txt
├── argocd/
│   └── application.yaml
├── k8s/
│   ├── deployment.yaml
│   ├── namespace.yaml
│   └── service.yaml
├── kind/
│   └── cluster.yaml
├── scripts/
│   ├── bootstrap_local.sh
│   ├── common.sh
│   ├── configure_gitops.sh
│   ├── install_argocd.sh
│   ├── load_image_into_kind.sh
│   ├── recover.sh
│   ├── simulate_failure.sh
│   └── status.sh
├── tests/
│   └── test_app.py
├── Dockerfile
└── Makefile
```

## What Is Automated

### CI

On every push to `main`, GitHub Actions:

1. runs tests,
2. builds the Docker image,
3. pushes the image to Docker Hub,
4. updates `k8s/deployment.yaml` with the new image tag,
5. commits that manifest change back to Git.

### CD

Argo CD watches the Git repository and continuously reconciles Kubernetes to the manifest stored in Git.

### Self-Healing

If a broken image tag is committed:

- Kubernetes reports pod failure,
- Argo CD marks the app as `Degraded`,
- `git revert` restores the previous good manifest,
- Argo CD automatically syncs back to the healthy version.

## Local Run Commands

Run unit tests:

```bash
make test
```

Bootstrap a local Kind cluster, build the app image, deploy Kubernetes resources, and install Argo CD:

```bash
make bootstrap-local
```

Check status:

```bash
make status
```

Simulate a bad deployment commit:

```bash
make break
```

Recover by Git revert:

```bash
make heal
```

## GitOps Configuration

Before Argo CD can sync from Git, configure the repository URL in [argocd/application.yaml](/home/azienackerman/Documents/Automated%20CICD%20PipeLine/self-healing-cicd-gitops/argocd/application.yaml):

```bash
./scripts/configure_gitops.sh https://github.com/YOUR_USER/self-healing-cicd-gitops.git docker.io/YOUR_USER/self-healing-app:latest 1.0.0
```

This command:

- sets the Argo CD `repoURL`,
- optionally updates the Kubernetes image reference,
- optionally updates `APP_VERSION`,
- applies the Argo CD application manifest to the cluster.

## GitHub Secrets Required

Add these repository secrets before enabling the CI workflow:

- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`

## Expected Runtime Outputs

Healthy app:

```json
{"message":"Self-healing CI/CD pipeline is running","status":"healthy","version":"1.0.0"}
```

Broken deployment symptoms:

```text
ImagePullBackOff
Health Status: Degraded
```

Recovered deployment symptoms:

```text
Sync Status: Synced
Health Status: Healthy
```

## Demonstration Flow

1. Push code to `main`.
2. GitHub Actions tests, builds, and publishes the container image.
3. The workflow updates `k8s/deployment.yaml` in Git.
4. Argo CD detects the Git change and syncs the cluster.
5. Commit a broken image tag.
6. Kubernetes fails to pull the image and Argo CD shows `Degraded`.
7. Run `git revert` or `make heal`.
8. Push the revert.
9. Argo CD restores the last healthy version automatically.
