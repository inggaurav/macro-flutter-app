import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/macro_service_config.dart';
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
  ];

  @override
  Future<List<TaskItem>> fetchTasks() async {
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
  final MacroServiceConfig _config;
  final String? Function() _tokenProvider;

  MacroTasksRepository({
    MacroServiceConfig? config,
    required String? Function() tokenProvider,
  }) : _config = config ?? MacroServiceConfig.production(),
       _tokenProvider = tokenProvider;

  @override
  Future<List<TaskItem>> fetchTasks() async {
    final token = _tokenProvider();
    if (token == null || token.isEmpty) return [];

    try {
      final response = await http
          .get(
            Uri.parse('${_config.storageHost}/v1/tasks'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((item) => TaskItem.fromJson(item)).toList();
      }
    } catch (_) {}

    return [];
  }

  @override
  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    final token = _tokenProvider();
    if (token == null || token.isEmpty) return;

    try {
      await http
          .patch(
            Uri.parse('${_config.storageHost}/v1/tasks/$taskId'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'status': status.name}),
          )
          .timeout(const Duration(seconds: 3));
    } catch (_) {}
  }

  @override
  Future<TaskItem> createTask(
    String title,
    String description,
    TaskPriority priority,
    String assigneeName,
  ) async {
    final token = _tokenProvider();
    final fallback = TaskItem(
      id: 't_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      status: TaskStatus.todo,
      priority: priority,
      assigneeName: assigneeName,
      assigneeAvatar:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
    );

    if (token == null || token.isEmpty) return fallback;

    try {
      final response = await http
          .post(
            Uri.parse('${_config.storageHost}/v1/tasks'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'title': title,
              'description': description,
              'priority': priority.name,
              'assignee_name': assigneeName,
            }),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return TaskItem.fromJson(data);
      }
    } catch (_) {}

    return fallback;
  }
}
