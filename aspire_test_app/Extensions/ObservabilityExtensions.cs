using OpenTelemetry.Logs;
using OpenTelemetry.Metrics;
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;

namespace AspireTestApp.Extensions;

public static class ObservabilityExtensions
{
    public static WebApplicationBuilder AddObservability(this WebApplicationBuilder builder)
    {
        var otlpEndpoint = builder.Configuration["OTEL_EXPORTER_OTLP_ENDPOINT"]
            ?? "http://otel-collector:4317"; // default gRPC

        var serviceName = Environment.GetEnvironmentVariable("OTEL_SERVICE_NAME") ?? "aspire-test-api";
        var resource = ResourceBuilder.CreateDefault()
            .AddService(serviceName: serviceName, serviceVersion: "1.0.0")
            .AddAttributes(
            [
                new("deployment.environment", builder.Environment.EnvironmentName)
            ]);

        // Logging
        builder.Logging.ClearProviders();
        builder.Logging.AddOpenTelemetry(o =>
        {
            o.IncludeScopes = true;
            o.IncludeFormattedMessage = true;
            o.SetResourceBuilder(resource);
            o.AddOtlpExporter(exp => exp.Endpoint = new Uri(otlpEndpoint));
            if (builder.Environment.IsDevelopment())
            {
                o.AddConsoleExporter();
            }
        });

        // Traces & Metrics
        builder.Services.AddOpenTelemetry()
            .ConfigureResource(r => r.AddService(serviceName))
            .WithTracing(t => t
                .AddAspNetCoreInstrumentation()
                .AddHttpClientInstrumentation()
                .AddOtlpExporter(o => o.Endpoint = new Uri(otlpEndpoint)))
            .WithMetrics(m => m
                .AddAspNetCoreInstrumentation()
                .AddHttpClientInstrumentation()
                .AddRuntimeInstrumentation()
                .AddMeter("AspireTestApp.Custom")
                .AddPrometheusExporter());

        return builder;
    }

    public static IApplicationBuilder UseObservabilityEndpoints(this IApplicationBuilder app)
    {
        // /metrics for Prometheus
        app.UseOpenTelemetryPrometheusScrapingEndpoint();
        return app;
    }
}
