Helm umbrella or individual chart customization will live here.

Proposed charts to manage via Helm (official/community):

- kube-prometheus-stack (Prometheus Operator, Alertmanager, Grafana)
- opentelemetry-collector
- jaeger (all-in-one dev or production strategy)
- loki (single binary or loki-distributed)

We will create values override files to replicate the current raw manifests setup.

# 1. Repos

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm repo update

# 2. Namespaces

kubectl create namespace observability || true
kubectl create namespace monitoring || true

# 3. Core installs (pin --version after checking `helm search repo <chart>` if desired)

helm upgrade --install loki grafana/loki \
 -n observability \
 -f helm/observability/values-loki.yaml

helm upgrade --install jaeger jaegertracing/jaeger \
 -n observability \
 -f helm/observability/values-jaeger.yaml

helm upgrade --install otel-collector open-telemetry/opentelemetry-collector \
 -n observability \
 -f helm/observability/values-otel-collector.yaml

helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
 -n monitoring \
 -f helm/observability/values-kube-prometheus-stack.yaml

# 4. (Optional) If you decide to run a standalone Grafana instead of the stack's built-in Grafana:

# helm upgrade --install grafana grafana/grafana \

# -n monitoring \

# -f helm/observability/values-grafana-datasources.yaml

# 5. Verify

kubectl get pods -n observability
kubectl get pods -n monitoring
kubectl get servicemonitors.monitoring.coreos.com -A | grep aspire

# 6. (Example) Add OTEL vars to an app (adjust namespace/name)

kubectl set env deployment/aspire-test-app -n aspire \
 OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector.observability.svc.cluster.local:4317 \
 OTEL_SERVICE_NAME=aspire-test-app \
 OTEL_RESOURCE_ATTRIBUTES=deployment.environment=dev
