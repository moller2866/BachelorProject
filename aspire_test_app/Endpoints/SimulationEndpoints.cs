namespace AspireTestApp.Endpoints;

public static class SimulationEndpoints
{
    public static IEndpointRouteBuilder MapSimulationEndpoints(this IEndpointRouteBuilder routes)
    {
        var group = routes.MapGroup("/simulate").WithTags("Simulation");

        group.MapPost("/external-call", async (IHttpClientFactory factory, ILogger<Program> logger) =>
        {
            logger.LogInformation("Making external HTTP call to httpbin.org");
            var client = factory.CreateClient("remote");
            var resp = await client.GetAsync("https://httpbin.org/status/200,500");

            if (resp.IsSuccessStatusCode)
            {
                logger.LogInformation("External call succeeded with status {StatusCode}", (int)resp.StatusCode);
            }
            else
            {
                logger.LogWarning("External call failed with status {StatusCode}", (int)resp.StatusCode);
            }

            return Results.Json(new { status = (int)resp.StatusCode });
        });

        group.MapGet("/failure", (ILogger<Program> logger) =>
        {
            logger.LogError("Simulated failure endpoint called - about to throw exception");
            throw new InvalidOperationException("Simulated failure for tracing/logging");
        });

        // INFO level logging endpoint
        group.MapGet("/info", (ILogger<Program> logger) =>
        {
            logger.LogInformation("Info endpoint called at {Time}", DateTime.UtcNow);
            logger.LogInformation("Processing simulated info request with correlation ID: {CorrelationId}", Guid.NewGuid());
            logger.LogInformation("Operation completed successfully");

            return Results.Ok(new
            {
                level = "INFO",
                message = "Information logged successfully",
                timestamp = DateTime.UtcNow
            });
        });

        // WARNING level logging endpoint
        group.MapGet("/warning", (ILogger<Program> logger) =>
        {
            logger.LogWarning("Warning endpoint called - simulating a degraded service condition");
            logger.LogWarning("Database connection pool is at {PercentUsed}% capacity", 85);
            logger.LogWarning("Cache hit ratio below threshold: {HitRatio}%", 45);

            return Results.Ok(new
            {
                level = "WARNING",
                message = "Warning conditions detected",
                timestamp = DateTime.UtcNow
            });
        });

        // ERROR level logging endpoint (without exception)
        group.MapGet("/error", (ILogger<Program> logger) =>
        {
            logger.LogError("Error endpoint called - simulating a recoverable error");
            logger.LogError("Failed to process order {OrderId}: Payment gateway timeout", "ORD-12345");
            logger.LogError("Retry attempt {AttemptNumber} failed for operation {OperationName}", 3, "ProcessPayment");

            return Results.Problem(
                detail: "Simulated error occurred",
                statusCode: 500,
                title: "Internal Server Error"
            );
        });

        // Mixed logs endpoint
        group.MapPost("/mixed-logs", async (ILogger<Program> logger, IHttpClientFactory factory) =>
        {
            logger.LogInformation("Starting mixed logs simulation");

            try
            {
                logger.LogInformation("Step 1: Validating request");
                await Task.Delay(100);

                logger.LogWarning("Step 2: Cache miss detected, fetching from source");
                await Task.Delay(50);

                logger.LogInformation("Step 3: Making external API call");
                var client = factory.CreateClient("remote");
                var response = await client.GetAsync("https://httpbin.org/delay/1");

                if (!response.IsSuccessStatusCode)
                {
                    logger.LogError("External API call failed with status {StatusCode}", (int)response.StatusCode);
                    return Results.Problem("External service unavailable", statusCode: 503);
                }

                logger.LogInformation("Step 4: Processing response data");
                await Task.Delay(100);

                logger.LogWarning("Step 5: Detected duplicate record, using existing");

                logger.LogInformation("Mixed logs simulation completed successfully");

                return Results.Ok(new
                {
                    message = "Mixed logs generated",
                    logsGenerated = new[] { "INFO", "WARNING", "ERROR" },
                    timestamp = DateTime.UtcNow
                });
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Unexpected error during mixed logs simulation");
                throw;
            }
        });

        // Batch logging endpoint
        group.MapGet("/batch/{count:int}", (int count, ILogger<Program> logger) =>
        {
            if (count > 100)
            {
                logger.LogWarning("Batch count {Count} exceeds recommended limit of 100", count);
                count = 100;
            }

            logger.LogInformation("Starting batch log generation for {Count} entries", count);

            for (int i = 0; i < count; i++)
            {
                var logLevel = i % 3;
                switch (logLevel)
                {
                    case 0:
                        logger.LogInformation("Batch entry {Index}: Processing item {ItemId}", i, Guid.NewGuid());
                        break;
                    case 1:
                        logger.LogWarning("Batch entry {Index}: Slow processing detected ({Duration}ms)", i, Random.Shared.Next(500, 1000));
                        break;
                    case 2:
                        logger.LogError("Batch entry {Index}: Validation failed for item", i);
                        break;
                }
            }

            logger.LogInformation("Batch log generation completed for {Count} entries", count);

            return Results.Ok(new
            {
                logsGenerated = count,
                timestamp = DateTime.UtcNow
            });
        });

        // Structured logging with rich context
        group.MapPost("/structured", (ILogger<Program> logger) =>
        {
            var userId = Guid.NewGuid();
            var sessionId = Guid.NewGuid();
            var requestId = Guid.NewGuid();

            using (logger.BeginScope(new Dictionary<string, object>
            {
                ["UserId"] = userId,
                ["SessionId"] = sessionId,
                ["RequestId"] = requestId,
                ["Environment"] = "Production"
            }))
            {
                logger.LogInformation("User authentication successful");
                logger.LogInformation("Loading user preferences");
                logger.LogWarning("User has {UnreadMessages} unread messages", Random.Shared.Next(100, 500));
                logger.LogInformation("Dashboard loaded in {LoadTime}ms", Random.Shared.Next(200, 800));
            }

            return Results.Ok(new
            {
                message = "Structured logs with scope generated",
                userId,
                sessionId,
                requestId,
                timestamp = DateTime.UtcNow
            });
        });

        return routes;
    }
}
