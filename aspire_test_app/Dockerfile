# Multi-stage build for Aspire Test App
# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy csproj and restore as distinct layers
COPY AspireTestApp.csproj ./
RUN dotnet restore AspireTestApp.csproj

# Copy the remaining source
COPY . .
RUN dotnet publish AspireTestApp.csproj -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage (ASP.NET Core)
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Environment configuration
ENV ASPNETCORE_URLS=http://+:8080 \
    ASPNETCORE_ENVIRONMENT=Production \
    DOTNET_EnableDiagnostics=0

# (Optional) OpenTelemetry env overrides (uncomment to customize)
# ENV OTEL_SERVICE_NAME=aspire-test-api \
#     OTEL_RESOURCE_ATTRIBUTES=deployment.environment=prod \
#     OTEL_METRICS_EXPORTER=none

# Copy published output
COPY --from=build /app/publish .

# Expose app port (HTTP) and metrics (same port /metrics)
EXPOSE 8080

# Health check (basic liveness)
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:8080/health/live || exit 1

ENTRYPOINT ["dotnet", "AspireTestApp.dll"]
