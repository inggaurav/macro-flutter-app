import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../config/macro_service_config.dart';
import '../core/auth/auth_repository.dart';
import '../design/components/app_empty_state.dart';
import '../design/tokens/app_colors.dart';
import '../design/tokens/app_spacing.dart';
import '../design/tokens/app_typography.dart';
import '../features/docs/docs_repository.dart';
import '../models/models.dart';
import '../providers/workspace_provider.dart';

class DocsView extends StatefulWidget {
  final WorkspaceProvider provider;

  const DocsView({super.key, required this.provider});

  @override
  State<DocsView> createState() => _DocsViewState();
}

class _DocsViewState extends State<DocsView> {
  late final DocsRepository _repository;
  List<DocumentItem> _docs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final authRepo = Provider.of<AuthRepository>(context, listen: false);
    _repository = MacroDocsRepository(
      config: MacroServiceConfig.production(),
      tokenProvider: () => authRepo.authToken,
    );
    _loadDocs();
  }

  Future<void> _loadDocs() async {
    final docs = await _repository.fetchDocuments();
    if (mounted) {
      setState(() {
        _docs = docs;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_docs.isEmpty) {
      return AppEmptyState(
        icon: Icons.article_outlined,
        title: 'No Documents Connected',
        subtitle:
            'Connect your Macro Workspace account to access live documents, specs, and CRDT wikis.',
        actionLabel: 'Refresh Documents',
        onAction: _loadDocs,
      );
    }

    final selectedDoc = _docs.firstWhere(
      (d) => d.id == widget.provider.selectedDocId,
      orElse: () => _docs.first,
    );
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Row(
        children: [
          Container(
            width: isMobile ? double.infinity : 300,
            decoration: const BoxDecoration(
              color: AppColors.surfaceDark,
              border: Border(right: BorderSide(color: AppColors.borderDark)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.borderDark),
                    ),
                  ),
                  child: Text(
                    'Docs & Wiki Specs',
                    style: AppTypography.title(context),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _docs.length,
                    itemBuilder: (context, index) {
                      final doc = _docs[index];
                      final isSelected = !isMobile && doc.id == selectedDoc.id;

                      return ListTile(
                        selected: isSelected,
                        selectedTileColor: AppColors.brandPrimary(
                          Provider.of<AppConfig>(context),
                        ).withValues(alpha: 0.15),
                        leading: const Icon(
                          Icons.article_outlined,
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
                        title: Text(
                          doc.title,
                          style: AppTypography.bodySmall(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => widget.provider.selectDoc(doc.id),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (!isMobile)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedDoc.title,
                      style: AppTypography.titleLarge(context),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          selectedDoc.content,
                          style: AppTypography.body(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
