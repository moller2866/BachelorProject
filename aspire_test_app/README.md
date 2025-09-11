# Aspire Test App (Standalone)

Simple .NET 8 minimal API to experiment with telemetry, resilience and Prometheus scraping without an Aspire AppHost.

## Endpoints

- GET / -> basic info
- GET /todos -> list
- GET /todos/{id}
- POST /todos { "title": "X" }
- POST /simulate/external-call -> calls httpbin with resilient HttpClient
- GET /simulate/failure -> throws exception (trace + 500)
- GET /health/live
- GET /health/ready
- GET /metrics -> Prometheus scrape (OpenTelemetry exporter)

## Resilience

Configured `AddStandardResilienceHandler()` on named HttpClient `remote` (retry, circuit breaker, timeout, etc.).

## Telemetry

OpenTelemetry Metrics & Traces with instrumentations:

- ASP.NET Core, HTTP, Runtime
- Custom meter: `AspireTestApp.Custom` counter `todos_created`
- Prometheus exporter middleware exposes /metrics

## Run

```
dotnet run --project AspireTestApp.csproj --urls http://localhost:5199
```

## Prometheus Scrape Example

Add to prometheus.yml:

```
scrape_configs:
  - job_name: 'aspire_test_app'
    scrape_interval: 5s
    static_configs:
      - targets: ['host.docker.internal:5199'] # adjust if running elsewhere
```

If Prometheus runs on the same host outside Docker, you can use `localhost:5199`.

## Grafana

Import Prometheus as a data source, then build panels using metrics (search for `aspire_test_api` resource attributes or `todos_created`).

## Next Ideas

- Add OTLP exporter for traces to Tempo/Jaeger.
- Expose readiness probe logic.
- Add histogram instruments for latency.
