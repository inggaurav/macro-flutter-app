import 'package:flutter/material.dart';
import '../design/components/app_card.dart';
import '../design/components/entity_chip.dart';
import '../design/tokens/app_colors.dart';
import '../design/tokens/app_radius.dart';
import '../design/tokens/app_spacing.dart';
import '../design/tokens/app_typography.dart';
import '../models/models.dart';
import '../providers/workspace_provider.dart';

class TasksView extends StatelessWidget {
  final WorkspaceProvider provider;

  const TasksView({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final tasks = provider.tasks;
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Column(
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(
              color: AppColors.surfaceDark,
              border: Border(bottom: BorderSide(color: AppColors.borderDark)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Engineering Tasks & Kanban',
                      style: AppTypography.title(context),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${tasks.length} tasks in active sprint',
                      style: AppTypography.caption(context),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: AppRadius.borderSm,
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.filter_list,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'All Priorities',
                        style: AppTypography.caption(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Body Content
          Expanded(
            child: isMobile
                ? ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) =>
                        _buildTaskCard(context, tasks[index]),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildKanbanColumn(
                        context,
                        'TO DO',
                        TaskStatus.todo,
                        tasks,
                      ),
                      _buildKanbanColumn(
                        context,
                        'IN PROGRESS',
                        TaskStatus.inProgress,
                        tasks,
                      ),
                      _buildKanbanColumn(
                        context,
                        'IN REVIEW',
                        TaskStatus.inReview,
                        tasks,
                      ),
                      _buildKanbanColumn(
                        context,
                        'DONE',
                        TaskStatus.done,
                        tasks,
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
    List<TaskItem> allTasks,
  ) {
    final columnTasks = allTasks.where((t) => t.status == status).toList();

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: AppRadius.borderMd,
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: AppTypography.label(context)),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: AppRadius.borderPill,
                    ),
                    child: Text(
                      '${columnTasks.length}',
                      style: AppTypography.caption(context),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.borderDark),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.sm),
                itemCount: columnTasks.length,
                itemBuilder: (context, index) =>
                    _buildTaskCard(context, columnTasks[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, TaskItem task) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              EntityChip(
                label: task.priority.name.toUpperCase(),
                type: EntityType.task,
              ),
              const Spacer(),
              CircleAvatar(
                radius: 10,
                backgroundImage: NetworkImage(task.assigneeAvatar),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            task.title,
            style: AppTypography.sectionTitle(context).copyWith(fontSize: 13),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            task.description,
            style: AppTypography.bodySmall(context),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
