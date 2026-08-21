import '../../models/models.dart';

abstract interface class TasksRepository {
  Future<List<TaskItem>> fetchTasks();
  Future<void> updateTaskStatus(String taskId, TaskStatus status);
  Future<TaskItem> createTask(
    String title,
    String description,
    TaskPriority priority,
    String assigneeName,
  );
}

class MockTasksRepository implements TasksRepository {
  final List<TaskItem> _tasks = [
    TaskItem(
      id: 't1',
      title:
          'Harden SecureStorageService with Android Keystore fail-closed semantics',
      description:
          'Ensure platform storage throws explicit exception rather than fallback silently to memory map.',
      status: TaskStatus.inProgress,
      priority: TaskPriority.urgent,
      assigneeName: 'Alex Rivera',
      assigneeAvatar:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
      dueDate: DateTime.now().add(const Duration(days: 1)),
      tags: ['Security', 'Storage'],
    ),
    TaskItem(
      id: 't2',
      title:
          'Decompose WorkspaceProvider into ChatController and InboxController',
      description:
          'Extract feature state out of raw monolithic WorkspaceProvider into dedicated controllers.',
      status: TaskStatus.todo,
      priority: TaskPriority.high,
      assigneeName: 'Alex Rivera',
      assigneeAvatar:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
      dueDate: DateTime.now().add(const Duration(days: 2)),
      tags: ['Architecture', 'Refactoring'],
    ),
    TaskItem(
      id: 't3',
      title:
          'Configure GitHub Actions CI workflow to use Flutter stable channel',
      description: 'Update .github/workflows/ci.yml with channel stable.',
      status: TaskStatus.done,
      priority: TaskPriority.medium,
      assigneeName: 'Devops Bot',
      assigneeAvatar:
          'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&q=80&w=200',
      dueDate: DateTime.now().subtract(const Duration(days: 1)),
      tags: ['CI/CD'],
    ),
  ];

  @override
  Future<List<TaskItem>> fetchTasks() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _tasks;
  }

  @override
  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      _tasks[idx].status = status;
    }
  }

  @override
  Future<TaskItem> createTask(
    String title,
    String description,
    TaskPriority priority,
    String assigneeName,
  ) async {
    final task = TaskItem(
      id: 't_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      status: TaskStatus.todo,
      priority: priority,
      assigneeName: assigneeName,
      assigneeAvatar:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
      dueDate: DateTime.now().add(const Duration(days: 3)),
      tags: ['Task'],
    );
    _tasks.add(task);
    return task;
  }
}

class MacroTasksRepository implements TasksRepository {
  @override
  Future<List<TaskItem>> fetchTasks() async {
    throw UnimplementedError('Macro API Tasks endpoints not yet configured.');
  }

  @override
  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    throw UnimplementedError('Macro API Tasks endpoints not yet configured.');
  }

  @override
  Future<TaskItem> createTask(
    String title,
    String description,
    TaskPriority priority,
    String assigneeName,
  ) async {
    throw UnimplementedError('Macro API Tasks endpoints not yet configured.');
  }
}
