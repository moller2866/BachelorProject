# Setup
Make sure kind is installed for the local cluster.
Run in Terminal:
1. ``kind create cluster --name lgtm-test --config kind-multinode.yaml``
2. ``kubectl cluster-info --context kind-lgtm-test``
3. ``kubectl create namespace observability``
4. ``kubectl config set-context --current --namespace=observability``

## Installing Minio with helm
1. ``kubectl apply -f minio.pod-yaml``
Note: Post pod will fail as no persistance is provided, this is fine as it is just a test environment, and it will run in memory.

## Installing Mimir with helm
1. ``helm repo add grafana https://grafana.github.io/helm-charts``
2. ``helm repo update``
3. ``helm install mimir grafana/mimir-distributed -f mimir-values.yaml --namespace observability``

## Installing Loki with helm
1. ``helm install loki grafana/loki-distributed -f loki-values.yaml --namespace observability``

## Installing Tempo with helm
1. ``helm install tempo grafana/tempo-distributed -f tempo-values.yaml --namespace observability``

## Installing OtelCollector with helm
1. ``helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts``
2. ``helm repo update``
3. ``helm install otel-collector open-telemetry/opentelemetry-collector -f otel-values.yaml --namespace observability``

# Running tests:
1. make sure open telemetry ports are forwarded
2. run this command: k6 run --out experimental-opentelemetry=http://localhost:4318 mimir-tests.js
