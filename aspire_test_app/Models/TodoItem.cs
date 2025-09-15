namespace AspireTestApp.Models;

/// <summary>
/// Represents a to-do item in the system.
/// </summary>
public sealed record TodoItem(int Id, string Title, bool Completed);

/// <summary>
/// DTO used when creating a new to-do item.
/// </summary>
public sealed record NewTodo(string Title);
