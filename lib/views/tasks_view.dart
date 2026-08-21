import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/macro_service_config.dart';
import '../core/auth/auth_repository.dart';
import '../design/components/app_empty_state.dart';
import '../design/tokens/app_colors.dart';
import '../design/tokens/app_spacing.dart';
import '../design/tokens/app_typography.dart';
import '../features/tasks/tasks_repository.dart';
import '../models/models.dart';
import '../providers/workspace_provider.dart';

class TasksView extends StatefulWidget {
  final WorkspaceProvider provider;

  const TasksView({super.key, required this.provider});

  @override
  State<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
  late final TasksRepository _repository;
  List<TaskItem> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final authRepo = Provider.of<AuthRepository>(context, listen: false);
    _repository = MacroTasksRepository(
      config: MacroServiceConfig.production(),
      tokenProvider: () => authRepo.authToken,
    );
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await _repository.fetchTasks();
    if (mounted) {
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_tasks.isEmpty) {
      return AppEmptyState(
        icon: Icons.check_box_outlined,
        title: 'No Active Tasks Connected',
        subtitle:
            'Connect your Macro Workspace account to view live engineering tasks, sprints, and Kanban items.',
        actionLabel: 'Refresh Tasks',
        onAction: _loadTasks,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: Text(task.title, style: AppTypography.body(context)),
          );
        },
      ),
    );
  }
}
