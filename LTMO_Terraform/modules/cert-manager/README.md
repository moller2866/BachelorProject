# cert-manager Module

This module deploys cert-manager to your Kubernetes cluster for automated certificate management.

## Overview

cert-manager is a Kubernetes add-on that automates the management and issuance of TLS certificates. It provides:

- Automatic certificate provisioning and renewal
- Support for multiple certificate issuers (Let's Encrypt, self-signed, CA, Vault, etc.)
- Kubernetes-native certificate management using CRDs
- Integration with Ingress controllers for automated TLS

## Features

- Deploys cert-manager v1.13.3 (configurable)
- Installs all required CRDs
- Creates dedicated namespace
- Configurable replica counts for high availability
- Prometheus metrics enabled by default
- Resource limits configured for production use

## Usage

```hcl
module "cert_manager" {
  source = "./modules/cert-manager"

  namespace              = "cert-manager"
  create_namespace       = true
  chart_version          = "v1.13.3"
  install_crds           = true
  enable_prometheus_metrics = true
}
```

## Inputs

| Name                      | Description                           | Type   | Default        | Required |
| ------------------------- | ------------------------------------- | ------ | -------------- | -------- |
| namespace                 | Kubernetes namespace for cert-manager | string | "cert-manager" | no       |
| create_namespace          | Create the namespace                  | bool   | true           | no       |
| chart_version             | Helm chart version                    | string | "v1.13.3"      | no       |
| install_crds              | Install CRDs                          | bool   | true           | no       |
| enable_prometheus_metrics | Enable Prometheus metrics             | bool   | true           | no       |
| replica_count             | Controller replicas                   | number | 1              | no       |
| webhook_replica_count     | Webhook replicas                      | number | 1              | no       |
| cainjector_replica_count  | CAInjector replicas                   | number | 1              | no       |

## Outputs

| Name           | Description                                   |
| -------------- | --------------------------------------------- |
| namespace      | The namespace where cert-manager is installed |
| release_name   | The Helm release name                         |
| release_status | The status of the Helm release                |
| chart_version  | The deployed chart version                    |
| ready          | Indicates cert-manager is ready               |

## Next Steps

After deploying cert-manager, you can:

1. Create ClusterIssuers for certificate authorities
2. Create Certificate resources
3. Configure Ingress resources to use automated TLS

See Phase 2 of the implementation for ClusterIssuer configuration.
