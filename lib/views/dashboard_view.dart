import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/workspace_provider.dart';
import '../theme/app_theme.dart';

class DashboardView extends StatelessWidget {
  final WorkspaceProvider provider;

  const DashboardView({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 0,
    );
    final totalArr = provider.deals.fold(0.0, (sum, d) => sum + d.value);

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Good morning, Alex 👋',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Here is your Macro workspace overview and AI team memory synthesis.',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryIndigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text(
                    'New Item',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => provider.setTab(WorkspaceTab.docs),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // AI Team Memory Synthesis Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryIndigo.withOpacity(0.2),
                    AppTheme.accentPurple.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryIndigo.withOpacity(0.4),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryIndigo,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'AI Shared Team Memory Daily Synthesis',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.accentEmerald.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'SYNCHRONIZED',
                                style: TextStyle(
                                  color: AppTheme.accentEmerald,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Acme Corp (\$120k ARR) proposal confirmed. CRDT Document sync benchmark passed SOC2 Type II compliance testing.',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textPrimary,
                      side: const BorderSide(color: AppTheme.borderDark),
                    ),
                    onPressed: () => provider.setTab(WorkspaceTab.aiMemory),
                    child: const Text('View Memory Log'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Key Telemetry Metric Cards
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(
                    width: 220,
                    child: _buildMetricCard(
                      title: 'Active Pipeline ARR',
                      value: currencyFormatter.format(totalArr),
                      icon: Icons.monetization_on_outlined,
                      color: AppTheme.accentEmerald,
                      subtitle: '3 Active CRM Deals',
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 220,
                    child: _buildMetricCard(
                      title: 'Unread Emails',
                      value:
                          '${provider.emails.where((e) => e.isUnread).length}',
                      icon: Icons.mail_outline,
                      color: AppTheme.primaryIndigo,
                      subtitle: 'Linked to CRM contacts',
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 220,
                    child: _buildMetricCard(
                      title: 'Open Tasks',
                      value:
                          '${provider.tasks.where((t) => t.status != TaskStatus.done).length}',
                      icon: Icons.check_box_outlined,
                      color: AppTheme.accentAmber,
                      subtitle: '1 Urgent priority',
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 220,
                    child: _buildMetricCard(
                      title: 'Active Call Room',
                      value: provider.callSessions.any((c) => c.isLive)
                          ? 'LIVE'
                          : 'Idle',
                      icon: Icons.videocam_outlined,
                      color: AppTheme.accentRose,
                      subtitle: 'AI Live Transcript',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Two Column Module Grid
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Recent Inbox & Active Tasks
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _buildSectionCard(
                        title: 'Recent Inbox Threads',
                        actionLabel: 'View All Emails',
                        onAction: () => provider.setTab(WorkspaceTab.inbox),
                        child: Column(
                          children: provider.emails.take(2).map((email) {
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.primaryIndigo
                                    .withOpacity(0.2),
                                child: Text(
                                  email.senderName[0],
                                  style: const TextStyle(
                                    color: AppTheme.primaryIndigo,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                email.subject,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              subtitle: Text(
                                email.preview,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              trailing: Text(
                                DateFormat('h:mm a').format(email.timestamp),
                                style: const TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                              onTap: () {
                                provider.selectEmail(email.id);
                                provider.setTab(WorkspaceTab.inbox);
                              },
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildSectionCard(
                        title: 'Active Priority Tasks',
                        actionLabel: 'Go to Kanban',
                        onAction: () => provider.setTab(WorkspaceTab.tasks),
                        child: Column(
                          children: provider.tasks.map((task) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    task.status == TaskStatus.done
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: task.status == TaskStatus.done
                                        ? AppTheme.accentEmerald
                                        : AppTheme.textMuted,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          task.title,
                                          style: TextStyle(
                                            color: AppTheme.textPrimary,
                                            fontWeight: FontWeight.w500,
                                            decoration:
                                                task.status == TaskStatus.done
                                                ? TextDecoration.lineThrough
                                                : null,
                                          ),
                                        ),
                                        Text(
                                          'Assignee: ${task.assigneeName}',
                                          style: const TextStyle(
                                            color: AppTheme.textMuted,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          task.priority == TaskPriority.urgent
                                          ? AppTheme.accentRose.withOpacity(0.2)
                                          : AppTheme.surfaceLightDark,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      task.priority.name.toUpperCase(),
                                      style: TextStyle(
                                        color:
                                            task.priority == TaskPriority.urgent
                                            ? AppTheme.accentRose
                                            : AppTheme.textSecondary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 20),

                // Right Column: CRM Deals & Active Docs
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildSectionCard(
                        title: 'CRM Sales Deals',
                        actionLabel: 'Open CRM',
                        onAction: () => provider.setTab(WorkspaceTab.crm),
                        child: Column(
                          children: provider.deals.map((deal) {
                            return ListTile(
                              leading: const Icon(
                                Icons.business,
                                color: AppTheme.primaryIndigo,
                              ),
                              title: Text(
                                deal.companyName,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              subtitle: Text(
                                deal.title,
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              trailing: Text(
                                currencyFormatter.format(deal.value),
                                style: const TextStyle(
                                  color: AppTheme.accentEmerald,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              onTap: () => provider.setTab(WorkspaceTab.crm),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildSectionCard(
                        title: 'Pinned Docs & PRDs',
                        actionLabel: 'View Docs',
                        onAction: () => provider.setTab(WorkspaceTab.docs),
                        child: Column(
                          children: provider.documents.map((doc) {
                            return ListTile(
                              leading: const Icon(
                                Icons.article_outlined,
                                color: AppTheme.accentCyan,
                              ),
                              title: Text(
                                doc.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                'Author: ${doc.authorName} • v${doc.versionCount}',
                                style: const TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                              onTap: () {
                                provider.selectDoc(doc.id);
                                provider.setTab(WorkspaceTab.docs);
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String actionLabel,
    required VoidCallback onAction,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: onAction,
                  child: Text(
                    actionLabel,
                    style: const TextStyle(
                      color: AppTheme.primaryIndigo,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          child,
        ],
      ),
    );
  }
}
