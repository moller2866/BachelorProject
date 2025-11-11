installCRDs: ${install_crds}

replicaCount: ${replica_count}

webhook:
  replicaCount: ${webhook_replica_count}

cainjector:
  replicaCount: ${cainjector_replica_count}

prometheus:
  enabled: ${enable_prometheus_metrics}

global:
  priorityClassName: ""
