namespace AspireTestApp.Endpoints;

public static class SimulationEndpoints
{
    public static IEndpointRouteBuilder MapSimulationEndpoints(this IEndpointRouteBuilder routes)
    {
        var group = routes.MapGroup("/simulate").WithTags("Simulation");

        group.MapPost("/external-call", async (IHttpClientFactory factory) =>
        {
            var client = factory.CreateClient("remote");
            var resp = await client.GetAsync("https://httpbin.org/status/200,500");
            return Results.Json(new { status = (int)resp.StatusCode });
        });

        group.MapGet("/failure", () =>
        {
            throw new InvalidOperationException("Simulated failure for tracing/logging");
        });

        return routes;
    }
}
