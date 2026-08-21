import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/macro_service_config.dart';
import '../core/auth/auth_repository.dart';
import '../design/components/app_empty_state.dart';
import '../design/tokens/app_colors.dart';
import '../design/tokens/app_spacing.dart';
import '../design/tokens/app_typography.dart';
import '../features/calls/calls_repository.dart';
import '../models/models.dart';
import '../providers/workspace_provider.dart';

class CallRoomView extends StatefulWidget {
  final WorkspaceProvider provider;

  const CallRoomView({super.key, required this.provider});

  @override
  State<CallRoomView> createState() => _CallRoomViewState();
}

class _CallRoomViewState extends State<CallRoomView> {
  late final CallsRepository _repository;
  List<CallSession> _calls = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final authRepo = Provider.of<AuthRepository>(context, listen: false);
    _repository = MacroCallsRepository(
      config: MacroServiceConfig.production(),
      tokenProvider: () => authRepo.authToken,
    );
    _loadCalls();
  }

  Future<void> _loadCalls() async {
    final calls = await _repository.fetchCalls();
    if (mounted) {
      setState(() {
        _calls = calls;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_calls.isEmpty) {
      return AppEmptyState(
        icon: Icons.video_call_outlined,
        title: 'No Call Records Connected',
        subtitle:
            'Connect your Macro Workspace account to access meeting recordings, live transcripts, and summaries.',
        actionLabel: 'Refresh Calls',
        onAction: _loadCalls,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: _calls.length,
        itemBuilder: (context, index) {
          final call = _calls[index];
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: Text(call.title, style: AppTypography.body(context)),
          );
        },
      ),
    );
  }
}
