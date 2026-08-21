import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/macro_service_config.dart';
import '../core/auth/auth_repository.dart';
import '../design/components/app_empty_state.dart';
import '../design/tokens/app_colors.dart';
import '../design/tokens/app_spacing.dart';
import '../design/tokens/app_typography.dart';
import '../features/agents/agent_repository.dart';
import '../models/models.dart';
import '../providers/workspace_provider.dart';

class AiMemoryView extends StatefulWidget {
  final WorkspaceProvider provider;

  const AiMemoryView({super.key, required this.provider});

  @override
  State<AiMemoryView> createState() => _AiMemoryViewState();
}

class _AiMemoryViewState extends State<AiMemoryView> {
  late final AgentRepository _repository;
  List<AiMemoryItem> _memories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final authRepo = Provider.of<AuthRepository>(context, listen: false);
    _repository = MacroAgentRepository(
      config: MacroServiceConfig.production(),
      tokenProvider: () => authRepo.authToken,
    );
    _loadMemories();
  }

  Future<void> _loadMemories() async {
    final memories = await _repository.fetchMemories();
    if (mounted) {
      setState(() {
        _memories = memories;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_memories.isEmpty) {
      return AppEmptyState(
        icon: Icons.psychology_outlined,
        title: 'Memory Unavailable',
        subtitle:
            'Connect your Macro Workspace account to fetch AI cognition team memories and knowledge provenance.',
        actionLabel: 'Refresh Memory',
        onAction: _loadMemories,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: _memories.length,
        itemBuilder: (context, index) {
          final mem = _memories[index];
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: Text(mem.title, style: AppTypography.body(context)),
          );
        },
      ),
    );
  }
}
