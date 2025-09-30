using AspireTestApp.Models;
using AspireTestApp.Services;

namespace AspireTestApp.Endpoints;

public static class TodoEndpoints
{
    public static IEndpointRouteBuilder MapTodoEndpoints(this IEndpointRouteBuilder routes)
    {
        var group = routes.MapGroup("/todos").WithTags("Todos");

        group.MapGet("/", (ITodoRepository repo) => Results.Ok(repo.GetAll()));
        group.MapGet("/{id:int}", (int id, ITodoRepository repo) =>
            repo.Get(id) is { } found ? Results.Ok(found) : Results.NotFound());
        group.MapPost("/", (NewTodo nt, ITodoRepository repo) =>
        {
            var created = repo.Add(nt);
            return Results.Created($"/todos/{created.Id}", created);
        });

        return routes;
    }
}
