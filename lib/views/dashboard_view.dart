import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../design/components/app_card.dart';
import '../design/components/entity_chip.dart';
import '../design/tokens/app_colors.dart';
import '../design/tokens/app_spacing.dart';
import '../design/tokens/app_typography.dart';
import '../features/inbox/controllers/inbox_controller.dart';
import '../models/models.dart';
import '../providers/workspace_provider.dart';
import '../repositories/auth_repository.dart';

class DashboardView extends StatelessWidget {
  final WorkspaceProvider provider;

  const DashboardView({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final authRepo = Provider.of<AuthRepository>(context);
    final appConfig = Provider.of<AppConfig>(context);
    final inboxController = Provider.of<InboxController>(context);
    final user = authRepo.currentUser;
    final currencyFormatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 0,
    );

    final unreadCount = inboxController.emails.where((e) => e.isUnread).length;
    final openTasks = <TaskItem>[];

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Workspace Greeting Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, ${user?.name ?? 'Alex'}',
                        style: AppTypography.titleLarge(context),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${appConfig.workspaceName} • Unified Workspace',
                        style: AppTypography.bodySmall(context),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.shield_outlined,
                        size: 14,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'System Operational',
                        style: AppTypography.caption(
                          context,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            // 2. Metrics Bar (Asymmetric Information Density)
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 700;
                final cards = [
                  _buildMetricTile(
                    context,
                    'Unread Emails',
                    '$unreadCount',
                    Icons.inbox_outlined,
                    AppColors.info,
                  ),
                  _buildMetricTile(
                    context,
                    'Active Tasks',
                    '${openTasks.length}',
                    Icons.check_box_outlined,
                    AppColors.warning,
                  ),
                  _buildMetricTile(
                    context,
                    'Pipeline Value',
                    currencyFormatter.format(120000),
                    Icons.pie_chart_outline,
                    AppColors.success,
                  ),
                  _buildMetricTile(
                    context,
                    'Realtime Sync',
                    '<45ms',
                    Icons.bolt,
                    AppColors.aiPurple,
                  ),
                ];

                if (isCompact) {
                  return Column(
                    children: cards
                        .map(
                          (c) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: c,
                          ),
                        )
                        .toList(),
                  );
                }

                return Row(
                  children: cards
                      .map(
                        (c) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              right: AppSpacing.md,
                            ),
                            child: c,
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),

            const SizedBox(height: AppSpacing.x2l),

            // 3. Priority Work Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 800;

                final leftColumn = Column(
                  children: [
                    // Inbox Section Card
                    AppCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Recent Inbox Threads',
                                  style: AppTypography.sectionTitle(context),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      provider.setTab(WorkspaceTab.inbox),
                                  child: Text(
                                    'View All',
                                    style: AppTypography.caption(
                                      context,
                                      color: AppColors.brandPrimary(appConfig),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1, color: AppColors.borderDark),
                          ...inboxController.emails.take(2).map((email) {
                            return Material(
                              color: Colors.transparent,
                              child: ListTile(
                                onTap: () {
                                  inboxController.selectEmail(email.id);
                                  provider.setTab(WorkspaceTab.inbox);
                                },
                                leading: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppColors.surfaceElevated,
                                  child: Text(
                                    email.senderName[0],
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  email.subject,
                                  style: AppTypography.sectionTitle(
                                    context,
                                  ).copyWith(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  email.preview,
                                  style: AppTypography.bodySmall(context),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Text(
                                  DateFormat('h:mm a').format(email.timestamp),
                                  style: AppTypography.caption(context),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Tasks Section Card
                    AppCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Active Engineering Tasks',
                                  style: AppTypography.sectionTitle(context),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      provider.setTab(WorkspaceTab.tasks),
                                  child: Text(
                                    'Go to Kanban',
                                    style: AppTypography.caption(
                                      context,
                                      color: AppColors.brandPrimary(appConfig),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1, color: AppColors.borderDark),
                          ...openTasks.map((task) {
                            return Material(
                              color: Colors.transparent,
                              child: ListTile(
                                leading: Icon(
                                  task.status == TaskStatus.done
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: task.status == TaskStatus.done
                                      ? AppColors.success
                                      : AppColors.warning,
                                  size: 18,
                                ),
                                title: Text(
                                  task.title,
                                  style: AppTypography.body(
                                    context,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                subtitle: Row(
                                  children: [
                                    EntityChip(
                                      label: task.priority.name.toUpperCase(),
                                      type: EntityType.task,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Due in 1 day',
                                      style: AppTypography.caption(context),
                                    ),
                                  ],
                                ),
                                onTap: () =>
                                    provider.setTab(WorkspaceTab.tasks),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                );

                final rightColumn = Column(
                  children: [
                    // AI Copilot Contextual Insight Card
                    AppCard(
                      backgroundColor: AppColors.surfaceElevated,
                      border: Border.all(
                        color: AppColors.aiPurple.withValues(alpha: 0.3),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.auto_awesome,
                                color: AppColors.aiPurple,
                                size: 18,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                'AI Workspace Synthesis',
                                style: AppTypography.sectionTitle(
                                  context,
                                  color: AppColors.aiPurple,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Multi-region real-time sync SLA target is <45ms. Offline session tokens are hardened via Android Keystore & iOS Keychain.',
                            style: AppTypography.body(context),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              const EntityChip(
                                label: 'CRDT Spec #d1',
                                type: EntityType.document,
                              ),
                              const SizedBox(width: 6),
                              const EntityChip(
                                label: '@vortex.io',
                                type: EntityType.deal,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Pinned Architecture Docs
                    AppCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Text(
                              'Pinned Specs & Architecture',
                              style: AppTypography.sectionTitle(context),
                            ),
                          ),
                          const Divider(height: 1, color: AppColors.borderDark),
                          Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Text(
                              'No Pinned Specs Connected',
                              style: AppTypography.bodySmall(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: leftColumn),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(flex: 2, child: rightColumn),
                    ],
                  );
                }

                return Column(
                  children: [
                    leftColumn,
                    const SizedBox(height: AppSpacing.lg),
                    rightColumn,
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.caption(context),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: AppTypography.sectionTitle(
                    context,
                  ).copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
