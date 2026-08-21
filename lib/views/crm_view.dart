import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/macro_service_config.dart';
import '../core/auth/auth_repository.dart';
import '../design/components/app_empty_state.dart';
import '../design/tokens/app_colors.dart';
import '../design/tokens/app_spacing.dart';
import '../design/tokens/app_typography.dart';
import '../features/crm/crm_repository.dart';
import '../models/models.dart';
import '../providers/workspace_provider.dart';

class CrmView extends StatefulWidget {
  final WorkspaceProvider provider;

  const CrmView({super.key, required this.provider});

  @override
  State<CrmView> createState() => _CrmViewState();
}

class _CrmViewState extends State<CrmView> {
  late final CrmRepository _repository;
  List<CrmDeal> _deals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final authRepo = Provider.of<AuthRepository>(context, listen: false);
    final serviceConfig = Provider.of<MacroServiceConfig>(
      context,
      listen: false,
    );
    _repository = MacroCrmRepository(
      config: serviceConfig,
      tokenProvider: () => authRepo.authToken,
    );
    _loadDeals();
  }

  Future<void> _loadDeals() async {
    final deals = await _repository.fetchDeals();
    if (mounted) {
      setState(() {
        _deals = deals;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_deals.isEmpty) {
      return AppEmptyState(
        icon: Icons.pie_chart_outline,
        title: 'No Enterprise Deals Connected',
        subtitle:
            'Connect your Macro Workspace account to view live company records, pipeline deals, and contacts.',
        actionLabel: 'Refresh Pipeline',
        onAction: _loadDeals,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: _deals.length,
        itemBuilder: (context, index) {
          final deal = _deals[index];
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: Text(deal.title, style: AppTypography.body(context)),
          );
        },
      ),
    );
  }
}
