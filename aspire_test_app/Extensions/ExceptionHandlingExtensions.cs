namespace AspireTestApp.Extensions;

public static class ExceptionHandlingExtensions
{
    public static IApplicationBuilder UseSimpleJsonExceptionHandler(this IApplicationBuilder app)
    {
        app.UseExceptionHandler(a =>
        {
            a.Run(async context =>
            {
                var error = context.Features.Get<Microsoft.AspNetCore.Diagnostics.IExceptionHandlerPathFeature>()?.Error;
                context.Response.StatusCode = 500;
                await context.Response.WriteAsJsonAsync(new { error = error?.Message });
            });
        });
        return app;
    }
}
