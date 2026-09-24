# Phase 5: GitOps with Flux

This phase adds GitOps using the Azure Flux extension. Manifests are stored in the `azure-gitops` repository.

## Prerequisites

Register the Kubernetes Configuration provider:

```bash
az provider register --namespace Microsoft.KubernetesConfiguration
```

## SSH Deploy Key Setup

1. Generate a key pair:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/azure-gitops -N "" -C "azure flux deploy key"
```

2. Add the public key to the iac-gitops repo:

```bash
gh repo deploy-key add ~/.ssh/azure-gitops.pub \
  --repo jeff-cevaal/azure-gitops \
  --title "azure flux deploy key" \
  --allow-write
```

## Deploy

```bash
terraform init
terraform plan
terraform apply
```

## Verify

```bash
kubectl get pods -n flux-system
kubectl get gitrepositories -n flux-system
kubectl get kustomizations -n flux-system
```
