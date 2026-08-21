import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../design/components/app_card.dart';
import '../design/components/entity_chip.dart';
import '../design/tokens/app_colors.dart';
import '../design/tokens/app_spacing.dart';
import '../design/tokens/app_typography.dart';
import '../models/models.dart';
import '../providers/workspace_provider.dart';

class CrmView extends StatelessWidget {
  final WorkspaceProvider provider;

  const CrmView({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final deals = provider.deals;
    final currencyFormatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 0,
    );

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CRM & Enterprise Pipeline',
                      style: AppTypography.title(context),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${deals.length} active enterprise deals',
                      style: AppTypography.caption(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: deals.length,
              itemBuilder: (context, index) {
                final deal = deals[index];
                return AppCard(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.business,
                          color: AppColors.success,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              deal.companyName,
                              style: AppTypography.sectionTitle(context),
                            ),
                            Text(
                              deal.title,
                              style: AppTypography.bodySmall(context),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                EntityChip(
                                  label: deal.stage.name.toUpperCase(),
                                  type: EntityType.deal,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  deal.contactName,
                                  style: AppTypography.caption(context),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text(
                        currencyFormatter.format(deal.value),
                        style: AppTypography.sectionTitle(
                          context,
                          color: AppColors.success,
                        ),
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
