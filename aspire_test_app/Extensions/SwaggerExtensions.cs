using Microsoft.OpenApi.Models;

namespace AspireTestApp.Extensions;

/// <summary>
/// Extension methods to add and use Swagger / OpenAPI for minimal APIs.
/// Enabled automatically in Development or when the environment variable ENABLE_SWAGGER=true.
/// </summary>
public static class SwaggerExtensions
{
    private const string EnableSwaggerVariable = "ENABLE_SWAGGER";

    /// <summary>
    /// Registers the services required for Swagger generation and API Explorer.
    /// Automatically includes XML comments when the XML documentation file exists.
    /// </summary>
    public static WebApplicationBuilder AddSwaggerDocumentation(this WebApplicationBuilder builder)
    {
        builder.Services.AddEndpointsApiExplorer();
        builder.Services.AddSwaggerGen(options =>
        {
            options.SwaggerDoc("v1", new OpenApiInfo
            {
                Title = "Aspire Test API",
                Version = "v1",
                Description = "Test API with OpenTelemetry instrumentation."
            });

            var xmlFile = $"{System.Reflection.Assembly.GetExecutingAssembly().GetName().Name}.xml";
            var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
            if (File.Exists(xmlPath))
            {
                options.IncludeXmlComments(xmlPath);
            }
        });
        return builder;
    }

    /// <summary>
    /// Adds the Swagger middleware (JSON + UI) if the environment is Development or ENABLE_SWAGGER=true.
    /// </summary>
    public static IApplicationBuilder UseSwaggerDocumentation(this IApplicationBuilder app)
    {
        var env = (app as WebApplication)?.Environment;
        var enabled = env?.IsDevelopment() == true ||
            string.Equals(Environment.GetEnvironmentVariable(EnableSwaggerVariable), "true", StringComparison.OrdinalIgnoreCase);

        if (!enabled)
        {
            return app; // no-op
        }

        app.UseSwagger();
        app.UseSwaggerUI(c =>
        {
            c.SwaggerEndpoint("/swagger/v1/swagger.json", "Aspire Test API v1");
            c.DisplayRequestDuration();
            c.EnableTryItOutByDefault();
        });

        return app;
    }
}
