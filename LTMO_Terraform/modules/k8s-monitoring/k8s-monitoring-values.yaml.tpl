---
# Sets the global scrape interval for Alloy components
global:
  scrapeInterval: ${scrape_interval}

# Global Label to be added to all telemetry data. Should reflect a recognizable name for the cluster.
cluster:
  name: ${cluster_name}

# Destinations for telemetry data (metrics, logs)
# The credentials are stored in the secrets metrics and logs
# Further authentication methods are supported, see the documentation (https://github.com/grafana/k8s-monitoring-helm/tree/main/charts/k8s-monitoring/docs/examples/auth)
destinations:
  - name: prometheus
    type: prometheus
    url: http://mimir-distributor.mimir.svc.cluster.local:8080/api/v1/push
    tenantId: "meta-monitoring"
    secret:
      create: true

  - name: loki
    type: loki
    url: http://loki-gateway.loki.svc.cluster.local/loki/api/v1/push
    tenantId: "meta-monitoring"
    secret:
      create: true

# Components to be monitored by the meta-monitoring Helm chart.
# Two integrations are being used:
# - alloy: https://github.com/grafana/k8s-monitoring-helm/blob/main/charts/k8s-monitoring/charts/feature-integrations/docs/integrations/alloy.md
# - loki: https://github.com/grafana/k8s-monitoring-helm/blob/main/charts/k8s-monitoring/charts/feature-integrations/docs/integrations/loki.md
integrations:
  collector: alloy-singleton
  alloy:
    instances:
      # monitor the collectors gathering and sending metrics/logs to the local cluster
      - name: alloy
        labelSelectors:
          app.kubernetes.io/name: [alloy-singleton]
        namespaces:
          - "${namespace}"

  loki:
    instances:
      - name: loki
        namespaces:
          - loki
        labelSelectors:
          app.kubernetes.io/name: loki
        logs:
          tuning:
            # extract logfmt fields and set them as structured metadata
            structuredMetadata:
              caller:
              tenant:
              org_id:
              user:

  mimir:
    instances:
      - name: mimir
        namespaces:
          - mimir
        labelSelectors:
          app.kubernetes.io/name: mimir
        logs:
          tuning:
            # extract logfmt fields and set them as structured metadata
            structuredMetadata:
              caller:
              tenant:
              org_id:
              user:
  tempo:
    instances:
      - name: tempo
        namespaces:
          - tempo
        labelSelectors:
          app.kubernetes.io/name: tempo
        logs:
          tuning:
            # extract logfmt fields and set them as structured metadata
            structuredMetadata:
              caller:
              tenant:
              org_id:
              user:
# (Optional) Kubernetes events are captured as logs and are annotated with additional metadata to make them easier to search and filter.
clusterEvents:
  enabled: ${enable_events}
  collector: alloy-singleton
  namespaces:
    - loki
    - mimir
    - tempo
# A collection of metric collectors that gather metrics from various sources in the cluster.
# (Required) cadvisor - Used to collect Loki pod metrics. Cadvisor is automatically deployed.
# kubelet - Kubernetes information on each node
# kubeletResource - Scrape resource metrics from the Kubelet.
# kube-state-metrics - A simple service that listens to the Kubernetes API server and generates metrics about the state of the objects.
clusterMetrics:
  enabled: ${enable_metrics}
  collector: alloy-singleton
  kubelet:
    enabled: true
  kubeletResource:
    enabled: true
  cadvisor:
    enabled: true
    metricsTuning:
      includeNamespaces:
        - loki
        - mimir
        - tempo
  apiServer:
    enabled: false
  kubeControllerManager:
    enabled: false
  kubeDNS:
    enabled: false
  kubeProxy:
    enabled: false
  kubeScheduler:
    enabled: false
  kube-state-metrics:
    enabled: true
    namespaces:
      - loki
      - mimir
      - tempo
    metricsTuning:
      useDefaultAllowList: false
      includeMetrics: [(.+)]
    podAnnotations:
      kubernetes.azure.com/set-kube-service-host-fqdn: "true"
  node-exporter:
    enabled: true
    deploy: true
    metricsTuning:
      useIntegrationAllowList: true
  windows-exporter:
    enabled: false
    deploy: false
  kepler:
    enabled: false
    deploy: false
  opencost:
    enabled: false
    deploy: false

nodeLogs:
  enabled: false

# Enable pod log collection for the cluster. Will collect logs from all pods in both the meta and loki namespace.
podLogs:
  enabled: ${enable_pod_logs}
  collector: alloy-singleton
  labelsToKeep:
    - app
    - app_kubernetes_io_name
    - component
    - container
    - job
    - level
    - namespace
    - service_name
    - cluster
  gatherMethod: kubernetesApi
  namespaces:
    - loki
    - mimir
    - tempo
  structuredMetadata:
    pod:

# Collectors
# The Alloy Singleton is a single instance of the Alloy Collector that is deployed in the cluster.
alloy-singleton:
  enabled: true
  controller:
    podAnnotations:
      kubernetes.azure.com/set-kube-service-host-fqdn: "true"

alloy-metrics:
  enabled: false

alloy-logs:
  enabled: false

alloy-profiles:
  enabled: false

alloy-receiver:
  enabled: false
