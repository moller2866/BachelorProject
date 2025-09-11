using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

// This mirrors a subset of what Aspire ServiceDefaults normally wires when used via AppHost.
// Keeps things explicit & minimal for standalone usage.
public static class ServiceDefaultsExtensions
{
    public static IHostApplicationBuilder AddServiceDefaults(this IHostApplicationBuilder builder)
    {
        // Logging already configured by default builder; could extend here if needed.

        // Add HTTP metrics & tracing conveniences if desired later.
        return builder;
    }
}
