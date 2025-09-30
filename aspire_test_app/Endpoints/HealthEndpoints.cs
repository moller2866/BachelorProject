using Microsoft.Extensions.Diagnostics.HealthChecks;

namespace AspireTestApp.Endpoints;

public static class HealthEndpoints
{
    public static IServiceCollection AddHealth(this IServiceCollection services)
    {
        services.AddHealthChecks().AddCheck("self", () => HealthCheckResult.Healthy(), tags: new[] { "live" });
        return services;
    }

    public static IEndpointRouteBuilder MapHealthEndpoints(this IEndpointRouteBuilder routes)
    {
        routes.MapHealthChecks("/health/live", new() { Predicate = r => r.Tags.Contains("live") });
        routes.MapHealthChecks("/health/ready");
        return routes;
    }
}
