# kubectl create namespace observability
kubectl create namespace aspire
helm repo add loki https://grafana.github.io/helm-charts
helm repo add mimir https://grafana.github.io/helm-charts
helm repo add tempo https://grafana.github.io/helm-charts
helm repo add otel-collector https://open-telemetry.github.io/opentelemetry-helm-charts
helm repo add minio https://charts.min.io/
helm repo update

# Deploy shared Minio first
helm upgrade --install minio minio/minio -n observability -f helm/minio-values.yaml --wait --create-namespace

# Deploy observability stack components
helm upgrade  --install loki grafana/loki -n observability -f helm/loki-values.yaml --create-namespace
helm upgrade  --install mimir grafana/mimir-distributed -n observability -f helm/mimir-values.yaml --create-namespace
helm upgrade  --install tempo grafana/tempo-distributed -n observability -f helm/tempo-values.yaml --create-namespace
helm upgrade  --install otel-collector open-telemetry/opentelemetry-collector -n observability -f helm/otel-collector-values.yaml --create-namespace

#helm upgrade --install grafana grafana/grafana -n observability --create-namespace \
#  --set adminPassword='supersecretpassword'

helm upgrade --install k8s-monitoring grafana/k8s-monitoring --namespace observability -f values.yaml

kubectl apply -f ../kubernetes/aks/app1/.
