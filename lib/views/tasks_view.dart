import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/workspace_provider.dart';
import '../theme/app_theme.dart';

class TasksView extends StatelessWidget {
  final WorkspaceProvider provider;

  const TasksView({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Column(
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.borderDark)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Tasks & Engineering Board',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Kanban views auto-updated from Slack messages, emails, and PRs',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryIndigo,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Task'),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Kanban Columns Grid
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(20),
              children: [
                _buildKanbanColumn(
                  context,
                  'TO DO',
                  TaskStatus.todo,
                  AppTheme.textMuted,
                ),
                _buildKanbanColumn(
                  context,
                  'IN PROGRESS',
                  TaskStatus.inProgress,
                  AppTheme.primaryIndigo,
                ),
                _buildKanbanColumn(
                  context,
                  'IN REVIEW',
                  TaskStatus.inReview,
                  AppTheme.accentAmber,
                ),
                _buildKanbanColumn(
                  context,
                  'DONE',
                  TaskStatus.done,
                  AppTheme.accentEmerald,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKanbanColumn(
    BuildContext context,
    String title,
    TaskStatus status,
    Color accentColor,
  ) {
    final columnTasks = provider.tasks
        .where((t) => t.status == status)
        .toList();

    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Column(
        children: [
          // Column Header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.borderDark)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLightDark,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${columnTasks.length}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Task Cards List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: columnTasks.length,
              itemBuilder: (context, index) {
                final task = columnTasks[index];
                return _buildTaskCard(context, task);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, TaskItem task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLightDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: task.priority == TaskPriority.urgent
                      ? AppTheme.accentRose.withOpacity(0.2)
                      : AppTheme.primaryIndigo.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  task.priority.name.toUpperCase(),
                  style: TextStyle(
                    color: task.priority == TaskPriority.urgent
                        ? AppTheme.accentRose
                        : AppTheme.primaryIndigo,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              PopupMenuButton<TaskStatus>(
                icon: const Icon(
                  Icons.more_horiz,
                  size: 16,
                  color: AppTheme.textMuted,
                ),
                color: AppTheme.surfaceDark,
                onSelected: (newStatus) =>
                    provider.updateTaskStatus(task.id, newStatus),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: TaskStatus.todo,
                    child: Text('Move to To Do'),
                  ),
                  const PopupMenuItem(
                    value: TaskStatus.inProgress,
                    child: Text('Move to In Progress'),
                  ),
                  const PopupMenuItem(
                    value: TaskStatus.inReview,
                    child: Text('Move to In Review'),
                  ),
                  const PopupMenuItem(
                    value: TaskStatus.done,
                    child: Text('Move to Done'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            task.title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            task.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 10,
                    backgroundImage: NetworkImage(task.assigneeAvatar),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    task.assigneeName.split(' ')[0],
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 12,
                    color: AppTheme.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM d').format(task.dueDate),
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
