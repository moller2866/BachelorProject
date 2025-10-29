global:
  podLabels:
    "azure.workload.identity/use": "true"

serviceAccount:
  name: "${service_account_name}"
  annotations:
    "azure.workload.identity/client-id": "${workload_identity_client_id}"
  labels:
    "azure.workload.identity/use": "true"

mimir:
  structuredConfig:
    common:
      storage:
        backend: azure
        azure:
          account_name: "${storage_account_name}"
          container_name: "${mimir_blocks_container}"

    blocks_storage:
      backend: azure
      azure:
        account_name: "${storage_account_name}"
        container_name: "${mimir_blocks_container}"

minio:
  enabled: false
ruler:
  enabled: false
alertmanager:
  enabled: false
nginx:
  enabled: true

compactor:
  replicas: 1

store_gateway:
  replicas: 1

ingester:
  replicas: 1

distributor:
  replicas: 2

query_frontend:
  replicas: 1

query_scheduler:
  replicas: 1

querier:
  replicas: 2

chunks-cache:
  enabled: false

memcached:
  enabled: false

persistence:
  enabled: true
  size: 20Gi

serviceMonitor:
  enabled: false
