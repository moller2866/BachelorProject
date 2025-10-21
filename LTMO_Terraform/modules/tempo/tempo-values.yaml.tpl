global:
  podLabels:
    "azure.workload.identity/use": "true"

serviceAccount:
  name: "${service_account_name}"
  annotations:
    "azure.workload.identity/client-id": "${workload_identity_client_id}"
  labels:
    "azure.workload.identity/use": "true"
  automountSerciveAccountToken: true

# Configuration for tempo-distributed chart
traces:
  otlp:
    grpc:
      enabled: true
    http:
      enabled: true

storage:
  trace:
    backend: azure
    azure:
      container_name: "${tempo_traces_container}"
      storage_account_name: "${storage_account_name}"
      use_federated_token: true

tempo:
  podLabels:
    "azure.workload.identity/use": "true"
  podAnnotations:
    "azure.workload.identity/client-id": "${workload_identity_client_id}"

# Distributor configuration
distributor:
  replicas: 1


# Ingester configuration
ingester:
  replicas: 1


# Compactor configuration  
compactor:
  replicas: 1


# Querier configuration
querier:
  replicas: 1

# Query Frontend configuration
queryFrontend:
  enabled: true

# Gateway configuration (for tempo-distributed)
gateway:
  enabled: true
  replicas: 1


# Memcached (optional, can be disabled for simple setups)
memcached:
  enabled: false

# Global configuration
config: |
  multitenancy_enabled: false
  usage_report:
    reporting_enabled: false
  compactor:
    compaction:
      block_retention: 24h
  distributor:
    receivers:
      otlp:
        protocols:
          grpc:
            endpoint: "0.0.0.0:4317"
          http:
            endpoint: "0.0.0.0:4318"
  ingester:
    lifecycler:
      ring:
        kvstore:
          store: memberlist
  querier:
    frontend_worker:
      frontend_address: tempo-query-frontend:9095
  query_frontend:
    max_outstanding_per_tenant: 100
  server:
    http_listen_port: 3200
    grpc_listen_port: 9095
  storage:
    trace:
      backend: azure
      azure:
        container_name: ${tempo_traces_container}
        storage_account_name: ${storage_account_name}
        use_federated_token: true
      wal:
        path: /var/tempo/wal
      local:
        path: /var/tempo/blocks
  memberlist:
    bind_port: 7946

serviceMonitor:
  enabled: false
