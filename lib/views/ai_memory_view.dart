import 'package:flutter/material.dart';
import '../design/components/app_card.dart';
import '../design/components/entity_chip.dart';
import '../design/tokens/app_colors.dart';
import '../design/tokens/app_spacing.dart';
import '../design/tokens/app_typography.dart';
import '../providers/workspace_provider.dart';

class AiMemoryView extends StatelessWidget {
  final WorkspaceProvider provider;

  const AiMemoryView({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final memories = provider.memories;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(
              color: AppColors.surfaceDark,
              border: Border(bottom: BorderSide(color: AppColors.borderDark)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: AppColors.aiPurple,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'AI Team Shared Memory',
                  style: AppTypography.title(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: memories.length,
              itemBuilder: (context, index) {
                final mem = memories[index];
                return AppCard(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  backgroundColor: AppColors.surfaceElevated,
                  border: Border.all(
                    color: AppColors.aiPurple.withOpacity(0.3),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            mem.title,
                            style: AppTypography.sectionTitle(
                              context,
                              color: AppColors.aiPurple,
                            ),
                          ),
                          EntityChip(
                            label: 'Source: ${mem.source}',
                            type: EntityType.agent,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        mem.summary,
                        style: AppTypography.body(
                          context,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          const Icon(
                            Icons.verified,
                            size: 14,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Confidence: ${(mem.confidence * 100).toInt()}%',
                            style: AppTypography.caption(
                              context,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
