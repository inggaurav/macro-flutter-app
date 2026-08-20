import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/workspace_provider.dart';
import '../theme/app_theme.dart';

class CrmView extends StatelessWidget {
  final WorkspaceProvider provider;

  const CrmView({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 0,
    );

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
                      'CRM & Deal Pipeline',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Colocated with team chat and email — @mention companies in channels to link history',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentEmerald,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Deal'),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Pipeline Columns
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(20),
              children: [
                _buildCrmColumn(
                  context,
                  'PROPOSAL',
                  DealStage.proposal,
                  AppTheme.primaryIndigo,
                  currencyFormatter,
                ),
                _buildCrmColumn(
                  context,
                  'NEGOTIATION',
                  DealStage.negotiation,
                  AppTheme.accentAmber,
                  currencyFormatter,
                ),
                _buildCrmColumn(
                  context,
                  'CLOSED WON',
                  DealStage.closedWon,
                  AppTheme.accentEmerald,
                  currencyFormatter,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrmColumn(
    BuildContext context,
    String title,
    DealStage stage,
    Color accentColor,
    NumberFormat currencyFormatter,
  ) {
    final stageDeals = provider.deals.where((d) => d.stage == stage).toList();
    final columnTotal = stageDeals.fold(0.0, (sum, d) => sum + d.value);

    return Container(
      width: 320,
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
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.borderDark)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${stageDeals.length} deals',
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  currencyFormatter.format(columnTotal),
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // Cards List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: stageDeals.length,
              itemBuilder: (context, index) {
                final deal = stageDeals[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
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
                          Text(
                            deal.companyName,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          PopupMenuButton<DealStage>(
                            icon: const Icon(
                              Icons.more_vert,
                              size: 16,
                              color: AppTheme.textMuted,
                            ),
                            color: AppTheme.surfaceDark,
                            onSelected: (newStage) =>
                                provider.updateDealStage(deal.id, newStage),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: DealStage.proposal,
                                child: Text('Move to Proposal'),
                              ),
                              const PopupMenuItem(
                                value: DealStage.negotiation,
                                child: Text('Move to Negotiation'),
                              ),
                              const PopupMenuItem(
                                value: DealStage.closedWon,
                                child: Text('Move to Closed Won'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        deal.title,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        currencyFormatter.format(deal.value),
                        style: const TextStyle(
                          color: AppTheme.accentEmerald,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.person_outline,
                            size: 14,
                            color: AppTheme.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${deal.contactName} (${deal.lastInteraction})',
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 11,
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
