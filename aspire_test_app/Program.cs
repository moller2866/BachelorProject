using AspireTestApp.Services;
using AspireTestApp.Endpoints;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using AspireTestApp.Extensions;

// -----------------------------------------------------------------------------
// Minimal .NET Web API w/ OpenTelemetry to an OTEL Collector
//   Traces  : OTLP -> Collector -> Jaeger
//   Metrics : Prometheus scrape (/metrics) -> Prometheus -> Grafana
//   Logs    : OTLP -> Collector -> Loki -> Grafana
// Environment (set via K8s Deployment / ConfigMap):
//   OTEL_EXPORTER_OTLP_ENDPOINT = http://otel-collector:4317   (gRPC)
//   Optional: OTEL_SERVICE_NAME, OTEL_RESOURCE_ATTRIBUTES, etc.
// -----------------------------------------------------------------------------

var builder = WebApplication.CreateBuilder(args);

// Observability (logging, traces, metrics)
builder.AddObservability();
// Swagger / OpenAPI
builder.AddSwaggerDocumentation();

// Health checks (liveness / readiness)
// Use extension method for consistency
builder.Services.AddHealth();

// Repository + outbound client
builder.Services.AddSingleton<ITodoRepository, InMemoryTodoRepository>();
builder.Services.AddHttpClient("remote");

var app = builder.Build();

app.UseSimpleJsonExceptionHandler();
app.UseSwaggerDocumentation();

app.MapGet("/", () => Results.Json(new { message = "Aspire test API", time = DateTime.UtcNow }));
app.MapHealthEndpoints();
app.MapTodoEndpoints();
app.MapSimulationEndpoints();

app.Run();
