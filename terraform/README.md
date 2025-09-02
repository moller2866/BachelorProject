# AKS Terraform

## Cloud:

### Login

```bash
az login
```

### Subscription

```
Cloud Services Local
```

### Create Service Principle

```bash
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/<SubscriptionID>" --name="BachelorProject"
```

### Set secrets

```bash
export ARM_CLIENT_ID="<ApplicationID>"
export ARM_CLIENT_SECRET="<PrincipalPassword>"
export ARM_SUBSCRIPTION_ID="<SubscriptionID>"
export ARM_TENANT_ID="<TenantID>"
```

## Setup

```bash
terraform init
```

```bash
terraform plan -out main.tfplan
```

```bash
terraform apply main.tfplan
```

Takes a long time to create VMs.. (approx 5 min)

## Get kubeconfig

```bash
resource_group_name=$(terraform output -raw resource_group_name)
```

```bash
az aks list --resource-group $resource_group_name --query "[].{\"K8s cluster name\":name}" --output table
```

```bash
echo "$(terraform output kube_config)" > ./azurek8s
export KUBECONFIG=./azurek8s
```

OR

```bash
az aks get-credentials --resource-group $resource_group_name --name bachelor-project-cluster --overwrite-existing
```

```bash
kubectl get nodes
```

## Prometheous and grafana:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

```bash
helm install my-kube-prometheus-stack prometheus-community/kube-prometheus-stack --version 77.2.0 --namespace monitoring --create-namespace
```
