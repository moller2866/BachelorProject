using OpenTelemetry.Logs;
using OpenTelemetry.Metrics;
using OpenTelemetry.Trace;

var builder = WebApplication.CreateBuilder(args);

builder.Logging.SetMinimumLevel(LogLevel.Information);

var otlpEndpoint = Environment.GetEnvironmentVariable("OTEL_EXPORTER_OTLP_ENDPOINT") ?? "http://aspire-dashboard:18889";

builder.Logging.AddOpenTelemetry(config =>
{
    config.IncludeFormattedMessage = true;
    config.AddOtlpExporter(o =>
    {
        o.Endpoint = new Uri(otlpEndpoint);
    });
});

builder.Services.AddOpenTelemetry()
    .WithMetrics(config =>
    {
        config.AddAspNetCoreInstrumentation();
        config.AddHttpClientInstrumentation();
        config.AddOtlpExporter(o =>
        {
            o.Endpoint = new Uri(otlpEndpoint); 
        });
    })
    .WithTracing(config =>
    {
        config.AddAspNetCoreInstrumentation();
        config.AddHttpClientInstrumentation();
        config.AddOtlpExporter(o =>
        {
            o.Endpoint = new Uri(otlpEndpoint);
        });
    });

builder.Services.Configure<OpenTelemetryLoggerOptions>(config =>
{
    config.AddOtlpExporter(o =>
    {
        o.Endpoint = new Uri(otlpEndpoint);
    });
});

var app = builder.Build();

app.MapGet("/", () => "Hello World!");

app.MapGet("/test", () => "Test!");

app.Run();
