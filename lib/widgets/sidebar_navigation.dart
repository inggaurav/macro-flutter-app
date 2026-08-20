import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../models/models.dart';
import '../providers/workspace_provider.dart';
import '../repositories/auth_repository.dart';
import '../theme/app_theme.dart';

class SidebarNavigation extends StatelessWidget {
  final WorkspaceProvider provider;

  const SidebarNavigation({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final appConfig = Provider.of<AppConfig>(context);
    final authRepo = Provider.of<AuthRepository>(context);
    final user = authRepo.currentUser;
    final flags = appConfig.featureFlags;

    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(right: BorderSide(color: AppTheme.borderDark)),
      ),
      child: Column(
        children: [
          // Dynamic App Branding Header
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
                    color: appConfig.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      appConfig.logoText,
                      style: const TextStyle(
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
                      Text(
                        appConfig.appName,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          const Icon(Icons.circle, size: 8, color: AppTheme.accentEmerald),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              appConfig.workspaceName,
                              style: const TextStyle(
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
              ],
            ),
          ),

          // Navigation Links
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              children: [
                _buildNavItem(
                  context,
                  tab: WorkspaceTab.dashboard,
                  icon: Icons.dashboard_outlined,
                  selectedIcon: Icons.dashboard,
                  label: 'Dashboard',
                ),
                _buildNavItem(
                  context,
                  tab: WorkspaceTab.inbox,
                  icon: Icons.mail_outline,
                  selectedIcon: Icons.mail,
                  label: 'Inbox',
                  badgeCount: provider.emails.where((e) => e.isUnread).length,
                ),
                _buildNavItem(
                  context,
                  tab: WorkspaceTab.chat,
                  icon: Icons.chat_bubble_outline,
                  selectedIcon: Icons.chat_bubble,
                  label: 'Channels & Chat',
                  badgeCount: provider.channels.fold(0, (sum, c) => sum + c.unreadCount),
                ),
                _buildNavItem(
                  context,
                  tab: WorkspaceTab.docs,
                  icon: Icons.description_outlined,
                  selectedIcon: Icons.description,
                  label: 'Docs & Wiki',
                ),
                _buildNavItem(
                  context,
                  tab: WorkspaceTab.tasks,
                  icon: Icons.check_box_outlined,
                  selectedIcon: Icons.check_box,
                  label: 'Engineering Tasks',
                  badgeCount: provider.tasks.where((t) => t.status != TaskStatus.done).length,
                ),

                if (flags['enableCrm'] ?? true)
                  _buildNavItem(
                    context,
                    tab: WorkspaceTab.crm,
                    icon: Icons.pie_chart_outline,
                    selectedIcon: Icons.pie_chart,
                    label: 'CRM & Deals',
                  ),

                if (flags['enableAiCopilot'] ?? true)
                  _buildNavItem(
                    context,
                    tab: WorkspaceTab.aiMemory,
                    icon: Icons.auto_awesome_outlined,
                    selectedIcon: Icons.auto_awesome,
                    label: 'AI Shared Memory',
                  ),

                if (flags['enableCalls'] ?? true)
                  _buildNavItem(
                    context,
                    tab: WorkspaceTab.calls,
                    icon: Icons.videocam_outlined,
                    selectedIcon: Icons.videocam,
                    label: 'Call Rooms & Notes',
                  ),

                const Divider(height: 24),
                _buildNavItem(
                  context,
                  tab: WorkspaceTab.settings,
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person,
                  label: 'Profile & Settings',
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
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(user?.avatarUrl ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Alex Rivera',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        user?.role ?? 'Lead Architect',
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, size: 16, color: AppTheme.textMuted),
                  onPressed: () => authRepo.logout(),
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
    required IconData selectedIcon,
    required String label,
    int badgeCount = 0,
  }) {
    final isSelected = provider.activeTab == tab;

    final appConfig = Provider.of<AppConfig>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        selected: isSelected,
        selectedTileColor: appConfig.primaryColor.withOpacity(0.15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        dense: true,
        leading: Icon(
          isSelected ? selectedIcon : icon,
          size: 18,
          color: isSelected ? appConfig.primaryColor : AppTheme.textMuted,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
        trailing: badgeCount > 0
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? appConfig.primaryColor : AppTheme.surfaceLightDark,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        onTap: () => provider.setTab(tab),
      ),
    );
  }
}
