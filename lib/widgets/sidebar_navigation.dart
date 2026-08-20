import 'package:flutter/material.dart';
import '../models/models.dart';
import '../providers/workspace_provider.dart';
import '../theme/app_theme.dart';

class SidebarNavigation extends StatelessWidget {
  final WorkspaceProvider provider;

  const SidebarNavigation({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: AppTheme.surfaceDark,
      child: Column(
        children: [
          // Macro Brand Header & Workspace Switcher
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.borderDark)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryIndigo,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryIndigo.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'M',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Macro Workspace',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Row(
                        children: const [
                          const Icon(Icons.circle, size: 8, color: AppTheme.accentEmerald),
                          const SizedBox(width: 4),
                          const Flexible(
                            child: Text(
                              'Macro Inc. Team',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.unfold_more, size: 18, color: AppTheme.textMuted),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Main Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                _buildNavItem(
                  context,
                  tab: WorkspaceTab.dashboard,
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  label: 'Dashboard',
                ),
                _buildNavItem(
                  context,
                  tab: WorkspaceTab.inbox,
                  icon: Icons.mail_outline,
                  activeIcon: Icons.mail,
                  label: 'Inbox',
                  badgeCount: provider.emails.where((e) => e.isUnread).length,
                ),
                _buildNavItem(
                  context,
                  tab: WorkspaceTab.chat,
                  icon: Icons.chat_bubble_outline,
                  activeIcon: Icons.chat_bubble,
                  label: 'Chat & Channels',
                  badgeCount: provider.channels.fold(0, (sum, c) => sum + c.unreadCount),
                ),
                _buildNavItem(
                  context,
                  tab: WorkspaceTab.docs,
                  icon: Icons.description_outlined,
                  activeIcon: Icons.description,
                  label: 'Docs & Wiki',
                ),
                _buildNavItem(
                  context,
                  tab: WorkspaceTab.tasks,
                  icon: Icons.check_box_outlined,
                  activeIcon: Icons.check_box,
                  label: 'Tasks & Boards',
                  badgeCount: provider.tasks.where((t) => t.status != TaskStatus.done).length,
                ),
                _buildNavItem(
                  context,
                  tab: WorkspaceTab.crm,
                  icon: Icons.pie_chart_outline,
                  activeIcon: Icons.pie_chart,
                  label: 'CRM & Deals',
                ),
                _buildNavItem(
                  context,
                  tab: WorkspaceTab.aiMemory,
                  icon: Icons.auto_awesome_outlined,
                  activeIcon: Icons.auto_awesome,
                  label: 'AI Memory & Swarm',
                  badgeColor: AppTheme.accentPurple,
                ),
                _buildNavItem(
                  context,
                  tab: WorkspaceTab.calls,
                  icon: Icons.videocam_outlined,
                  activeIcon: Icons.videocam,
                  label: 'Calls & Notes',
                  isLiveCall: provider.callSessions.any((c) => c.isLive),
                ),
              ],
            ),
          ),

          // User Profile Footer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppTheme.borderDark)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Alex Rivera',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Lead Architect',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined, size: 18),
                  onPressed: () => provider.setTab(WorkspaceTab.settings),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required WorkspaceTab tab,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    int badgeCount = 0,
    Color? badgeColor,
    bool isLiveCall = false,
  }) {
    final isActive = provider.activeTab == tab;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => provider.setTab(tab),
          hoverColor: AppTheme.surfaceLightDark,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? AppTheme.primaryIndigo.withOpacity(0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isActive
                  ? Border.all(color: AppTheme.primaryIndigo.withOpacity(0.4))
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  size: 20,
                  color: isActive ? AppTheme.primaryIndigo : AppTheme.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isActive ? AppTheme.textPrimary : AppTheme.textSecondary,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (isLiveCall)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.accentRose,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else if (badgeCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeColor ?? AppTheme.primaryIndigo,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
