# Aspire Test App

Refactored .NET 8 minimal API showcasing OpenTelemetry (traces, metrics, logs) with a clean composition root.

## Structure

```
Models/                  Domain records (TodoItem, NewTodo)
Services/                Abstractions & implementations (ITodoRepository, InMemoryTodoRepository)
Endpoints/               Endpoint mapping extensions (Todo, Simulation, Health)
Extensions/              Cross-cutting concerns (Observability, Exception handling)
Program.cs               Composition only
```

## Endpoints

| Area       | Endpoint                     | Description                       |
| ---------- | ---------------------------- | --------------------------------- |
| Root       | GET /                        | Basic info                        |
| Todos      | GET /todos                   | List todos                        |
| Todos      | GET /todos/{id}              | Get by id                         |
| Todos      | POST /todos                  | Create (JSON { "title": "X" })    |
| Simulation | POST /simulate/external-call | Outbound call (traces resiliency) |
| Simulation | GET /simulate/failure        | Throws exception (error tracing)  |
| Health     | GET /health/live             | Liveness probe                    |
| Health     | GET /health/ready            | Readiness probe                   |
| Metrics    | GET /metrics                 | Prometheus scrape                 |

## Observability

Implemented in `Extensions/ObservabilityExtensions.cs`:

- Logs, traces, metrics via OpenTelemetry
- OTLP exporter endpoint configured by `OTEL_EXPORTER_OTLP_ENDPOINT` (default `http://otel-collector:4317`)
- Prometheus exporter (scrape `/metrics`)
- Resource attributes include `deployment.environment` and service name from `OTEL_SERVICE_NAME`

Custom meter: `AspireTestApp.Custom`, counter: `todos_created`.

## Exception Handling

Unified JSON envelope via `UseSimpleJsonExceptionHandler()`; errors return:

```
{ "error": "<message>" }
```

## Adding a New Feature

1. Add models (if needed) under `Models/`.
2. Define interfaces / services under `Services/`.
3. Create an endpoint extension: `Endpoints/FeatureEndpoints.cs` with `MapFeatureEndpoints`.
4. Call the mapper in `Program.cs`.
5. Register services (e.g., `builder.Services.AddSingleton<IFoo, Foo>();`).

## Running

```
dotnet run --project AspireTestApp.csproj --urls http://localhost:5199
```

## Prometheus Scrape Example

```
scrape_configs:
  - job_name: 'aspire_test_app'
    scrape_interval: 5s
    static_configs:
      - targets: ['host.docker.internal:5199']
```

## Next Ideas

- Persist todos (EF Core / LiteDB) behind `ITodoRepository`.
- Add request logging & correlation IDs.
- Introduce API versioning groups.
- Add histogram instruments for latency & queue length.
