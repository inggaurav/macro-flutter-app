import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../design/components/app_card.dart';
import '../design/components/entity_chip.dart';
import '../design/tokens/app_colors.dart';
import '../design/tokens/app_spacing.dart';
import '../design/tokens/app_typography.dart';
import '../models/models.dart';
import '../providers/workspace_provider.dart';

class DocsView extends StatelessWidget {
  final WorkspaceProvider provider;

  const DocsView({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final docs = provider.documents;
    final selectedDoc = docs.firstWhere(
      (d) => d.id == provider.selectedDocId,
      orElse: () => docs.first,
    );
    final isMobile = MediaQuery.of(context).size.width < 768;

    final docListWidget = Container(
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
              border: Border(bottom: BorderSide(color: AppColors.borderDark)),
            ),
            child: Text(
              'Docs & Wiki Specs',
              style: AppTypography.title(context),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final isSelected = !isMobile && doc.id == selectedDoc.id;

                return Material(
                  color: Colors.transparent,
                  child: ListTile(
                    selected: isSelected,
                    selectedTileColor: AppColors.brandPrimary(
                      Provider.of<AppConfig>(context),
                    ).withOpacity(0.15),
                    leading: const Icon(
                      Icons.article_outlined,
                      color: AppColors.aiCyan,
                      size: 20,
                    ),
                    title: Text(
                      doc.title,
                      style: AppTypography.sectionTitle(
                        context,
                      ).copyWith(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      'v${doc.versionCount} • ${doc.authorName}',
                      style: AppTypography.caption(context),
                    ),
                    onTap: () => provider.selectDoc(doc.id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );

    if (isMobile) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: docListWidget,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Row(
        children: [
          docListWidget,
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.x2l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedDoc.title,
                        style: AppTypography.display(
                          context,
                        ).copyWith(fontSize: 22),
                      ),
                      const EntityChip(
                        label: 'CRDT Synced',
                        type: EntityType.document,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Author: ${selectedDoc.authorName} • Version ${selectedDoc.versionCount}',
                    style: AppTypography.bodySmall(context),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const Divider(color: AppColors.borderDark),
                  const SizedBox(height: AppSpacing.lg),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        selectedDoc.content,
                        style: AppTypography.bodyLarge(
                          context,
                          color: AppColors.textPrimary,
                        ).copyWith(height: 1.6),
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
