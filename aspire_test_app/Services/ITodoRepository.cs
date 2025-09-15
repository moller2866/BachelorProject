using AspireTestApp.Models;

namespace AspireTestApp.Services;

/// <summary>
/// Abstraction for accessing and mutating to-do items.
/// </summary>
public interface ITodoRepository
{
    /// <summary>Returns all to-do items.</summary>
    IReadOnlyCollection<TodoItem> GetAll();
    /// <summary>Gets a single to-do item by id or null if not found.</summary>
    TodoItem? Get(int id);
    /// <summary>Adds a new to-do item from input DTO and returns the created entity.</summary>
    TodoItem Add(NewTodo newTodo);
}
