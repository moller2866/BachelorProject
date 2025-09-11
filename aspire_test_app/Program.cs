using System.Diagnostics.Metrics;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using OpenTelemetry.Logs;
using OpenTelemetry.Metrics;
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;

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

// Resolve OTLP endpoint (fallback to typical in-cluster service name)
var otlpEndpoint = builder.Configuration["OTEL_EXPORTER_OTLP_ENDPOINT"]
    ?? "http://otel-collector:4317"; // gRPC port

// Shared resource (service identity & version)
var serviceName = Environment.GetEnvironmentVariable("OTEL_SERVICE_NAME") ?? "aspire-test-api";
var resource = ResourceBuilder.CreateDefault()
    .AddService(serviceName: serviceName, serviceVersion: "1.0.0")
    .AddAttributes(new KeyValuePair<string, object>[]
    {
        new("deployment.environment", builder.Environment.EnvironmentName)
    });

// -------------------- Logging (OTLP -> Collector -> Loki) --------------------
builder.Logging.ClearProviders(); // keep clean; add console only in dev
builder.Logging.AddOpenTelemetry(o =>
{
    o.IncludeScopes = true;
    o.IncludeFormattedMessage = true;
    o.SetResourceBuilder(resource);
    o.AddOtlpExporter(exp => exp.Endpoint = new Uri(otlpEndpoint));
    if (builder.Environment.IsDevelopment())
    {
        o.AddConsoleExporter(); // handy locally
    }
});

// ---------------- Traces & Metrics instrumentation configuration -------------
builder.Services.AddOpenTelemetry()
    .ConfigureResource(r => r.AddService(serviceName)) // simple merge
    .WithTracing(t => t
        .AddAspNetCoreInstrumentation()
    .AddHttpClientInstrumentation()
        .AddOtlpExporter(o => o.Endpoint = new Uri(otlpEndpoint)))
    .WithMetrics(m => m
        .AddAspNetCoreInstrumentation()
        .AddHttpClientInstrumentation()
        .AddRuntimeInstrumentation()
        .AddMeter("AspireTestApp.Custom")
        // Prometheus exporter exposes scrape endpoint; Prom server scrapes it
        .AddPrometheusExporter());

// Health checks (liveness / readiness)
builder.Services.AddHealthChecks()
    .AddCheck("self", () => HealthCheckResult.Healthy(), tags: new[] { "live" });

// Example in-memory data + custom metric
var todos = new List<TodoItem> { new(1, "Initial", false) };
Meter customMeter = new("AspireTestApp.Custom", "1.0");
var todoCounter = customMeter.CreateCounter<long>("todos_created");

// Simple outbound client to show trace spans
builder.Services.AddHttpClient("remote");

var app = builder.Build();

// Expose health
app.MapHealthChecks("/health/live", new() { Predicate = r => r.Tags.Contains("live") });
app.MapHealthChecks("/health/ready");

// Expose /metrics for Prometheus scrapes
app.UseOpenTelemetryPrometheusScrapingEndpoint();

app.MapGet("/", () => Results.Json(new { message = "Aspire test API", time = DateTime.UtcNow }));

app.MapGet("/todos", () => Results.Ok(todos));

app.MapGet("/todos/{id:int}", (int id) =>
    todos.FirstOrDefault(t => t.Id == id) is { } found
        ? Results.Ok(found)
        : Results.NotFound());

app.MapPost("/todos", (NewTodo nt) =>
{
    var id = todos.Count == 0 ? 1 : todos.Max(t => t.Id) + 1;
    var item = new TodoItem(id, nt.Title, false);
    todos.Add(item);
    todoCounter.Add(1);
    return Results.Created($"/todos/{id}", item);
});

app.MapPost("/simulate/external-call", async (IHttpClientFactory factory) =>
{
    var client = factory.CreateClient("remote");
    var resp = await client.GetAsync("https://httpbin.org/status/200,500");
    return Results.Json(new { status = (int)resp.StatusCode });
});

app.MapGet("/simulate/failure", () =>
{
    // Demonstrates an exception -> trace span w/ error + log
    throw new InvalidOperationException("Simulated failure for tracing/logging");
});

// Simple JSON error envelope
app.UseExceptionHandler(a =>
{
    a.Run(async context =>
    {
        var error = context.Features.Get<Microsoft.AspNetCore.Diagnostics.IExceptionHandlerPathFeature>()?.Error;
        context.Response.StatusCode = 500;
        await context.Response.WriteAsJsonAsync(new { error = error?.Message });
    });
});

app.Run();

record TodoItem(int Id, string Title, bool Completed);
record NewTodo(string Title);
