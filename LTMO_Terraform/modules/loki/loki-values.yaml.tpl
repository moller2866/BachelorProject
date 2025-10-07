loki:
  podLabels:
    "azure.workload.identity/use": "true"
  schemaConfig:
    configs:
      - from: "2024-04-01"
        store: tsdb
        object_store: azure
        schema: v13
        index:
          prefix: loki_index_
          period: 24h
  storage_config:
    azure:
      account_name: "${storage_account_name}"
      container_name: "${loki_chunk_container}"
      use_federated_token: true
  ingester:
    chunk_encoding: snappy
  pattern_ingester:
    enabled: true
  limits_config:
    allow_structured_metadata: true
    volume_enabled: true
    retention_period: 672h # 28 days retention
  compactor:
    retention_enabled: true
    delete_request_store: azure
  ruler:
    enable_api: true
    storage:
      type: azure
      azure:
        account_name: "${storage_account_name}"
        container_name: "${loki_ruler_container}"
        use_federated_token: true
      alertmanager_url: http://prom:9093

  querier:
    max_concurrent: 4

  storage:
    type: azure
    bucketNames:
      chunks: "${loki_chunk_container}"
      ruler: "${loki_ruler_container}"
    azure:
      accountName: "${storage_account_name}"
      useFederatedToken: true

serviceAccount:
  name: "${service_account_name}"
  annotations:
    "azure.workload.identity/client-id": "${workload_identity_client_id}"
  labels:
    "azure.workload.identity/use": "true"

deploymentMode: Distributed

ingester:
  replicas: 2
  zoneAwareReplication:
    enabled: false

querier:
  replicas: 2
  maxUnavailable: 1

queryFrontend:
  replicas: 2
  maxUnavailable: 1

queryScheduler:
  replicas: 2

distributor:
  replicas: 2
  maxUnavailable: 1

compactor:
  replicas: 1

indexGateway:
  replicas: 2
  maxUnavailable: 1

ruler:
  replicas: 1
  maxUnavailable: 1

gateway:
  service:
    type: LoadBalancer
  basicAuth:
    enabled: true
    existingSecret: loki-basic-auth

lokiCanary:
  extraArgs:
    - -pass=$(LOKI_PASS)
    - -user=$(LOKI_USER)
  extraEnv:
    - name: LOKI_PASS
      valueFrom:
        secretKeyRef:
          name: canary-basic-auth
          key: password
    - name: LOKI_USER
      valueFrom:
        secretKeyRef:
          name: canary-basic-auth
          key: username

minio:
  enabled: false
memcached:
  enabled: false
chunks-cache:
  enabled: false

backend:
  replicas: 0
read:
  replicas: 0
write:
  replicas: 0

singleBinary:
  replicas: 0
