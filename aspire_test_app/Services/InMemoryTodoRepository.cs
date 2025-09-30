using System.Diagnostics.Metrics;
using AspireTestApp.Models;

namespace AspireTestApp.Services;

/// <summary>
/// In-memory implementation of <see cref="ITodoRepository"/> for demo / dev use.
/// Not thread-safe; suitable only for single instance scenarios.
/// </summary>
public class InMemoryTodoRepository : ITodoRepository
{
    private readonly List<TodoItem> _items = new() { new TodoItem(1, "Initial", false) };
    private readonly Counter<long> _createdCounter;

    /// <summary>
    /// Creates the repository and registers custom metrics.
    /// </summary>
    public InMemoryTodoRepository(IMeterFactory meterFactory)
    {
        var meter = meterFactory.Create("AspireTestApp.Custom");
        _createdCounter = meter.CreateCounter<long>("todos_created", description: "Number of todos created");
    }

    /// <inheritdoc />
    public IReadOnlyCollection<TodoItem> GetAll() => _items.AsReadOnly();

    /// <inheritdoc />
    public TodoItem? Get(int id) => _items.FirstOrDefault(t => t.Id == id);

    /// <inheritdoc />
    public TodoItem Add(NewTodo newTodo)
    {
        var id = _items.Count == 0 ? 1 : _items.Max(t => t.Id) + 1;
        var item = new TodoItem(id, newTodo.Title, false);
        _items.Add(item);
        _createdCounter.Add(1);
        return item;
    }
}
