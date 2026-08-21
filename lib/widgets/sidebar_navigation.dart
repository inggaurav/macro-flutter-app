import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../design/components/command_palette.dart';
import '../design/tokens/app_colors.dart';
import '../design/tokens/app_radius.dart';
import '../design/tokens/app_spacing.dart';
import '../design/tokens/app_typography.dart';
import '../features/chat/controllers/chat_controller.dart';
import '../features/inbox/controllers/inbox_controller.dart';
import '../providers/workspace_provider.dart';
import '../repositories/auth_repository.dart';

class SidebarNavigation extends StatelessWidget {
  final WorkspaceProvider provider;

  const SidebarNavigation({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final appConfig = Provider.of<AppConfig>(context);
    final authRepo = Provider.of<AuthRepository>(context);
    final user = authRepo.currentUser;
    final avatarUrl = user?.avatarUrl.trim() ?? '';
    final flags = appConfig.featureFlags;

    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border(right: BorderSide(color: AppColors.borderDark)),
      ),
      child: Column(
        children: [
          // Header / Workspace Branding Identity
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.borderDark)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: appConfig.primaryColor,
                    borderRadius: AppRadius.borderSm,
                    boxShadow: [
                      BoxShadow(
                        color: appConfig.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      appConfig.logoText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appConfig.appName,
                        style: AppTypography.sectionTitle(context),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        appConfig.workspaceName,
                        style: AppTypography.caption(context),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Command Palette Search Trigger Button
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: AppRadius.borderSm,
                onTap: () => CommandPalette.show(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: AppRadius.borderSm,
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Search... (Ctrl+K)',
                          style: AppTypography.bodySmall(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Grouped Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              children: [
                _buildSectionHeader(context, 'WORKSPACE'),
                _buildNavItem(
                  context,
                  tab: WorkspaceTab.dashboard,
                  icon: Icons.dashboard_outlined,
                  selectedIcon: Icons.dashboard,
                  label: 'Home Dashboard',
                ),
                _buildNavItem(
                  context,
                  tab: WorkspaceTab.inbox,
                  icon: Icons.inbox_outlined,
                  selectedIcon: Icons.inbox,
                  label: 'Inbox',
                  badgeCount: Provider.of<InboxController>(
                    context,
                  ).emails.where((e) => e.isUnread).length,
                ),
                _buildNavItem(
                  context,
                  tab: WorkspaceTab.chat,
                  icon: Icons.chat_bubble_outline,
                  selectedIcon: Icons.chat_bubble,
                  label: 'Channels & Chat',
                  badgeCount: Provider.of<ChatController>(
                    context,
                  ).channels.fold(0, (sum, c) => sum + c.unreadCount),
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
                  label: 'Tasks & Kanban',
                  badgeCount: 0,
                ),

                if (flags['enableCrm'] ?? true) ...[
                  const SizedBox(height: AppSpacing.md),
                  _buildSectionHeader(context, 'BUSINESS'),
                  _buildNavItem(
                    context,
                    tab: WorkspaceTab.crm,
                    icon: Icons.pie_chart_outline,
                    selectedIcon: Icons.pie_chart,
                    label: 'CRM & Deals',
                  ),
                ],

                if (flags['enableAiCopilot'] ?? true) ...[
                  const SizedBox(height: AppSpacing.md),
                  _buildSectionHeader(context, 'INTELLIGENCE'),
                  _buildNavItem(
                    context,
                    tab: WorkspaceTab.aiMemory,
                    icon: Icons.auto_awesome_outlined,
                    selectedIcon: Icons.auto_awesome,
                    label: 'AI Shared Memory',
                  ),
                ],

                const SizedBox(height: AppSpacing.md),
                _buildSectionHeader(context, 'COMMUNICATION'),
                _buildNavItem(
                  context,
                  tab: WorkspaceTab.calls,
                  icon: Icons.video_camera_front_outlined,
                  selectedIcon: Icons.video_camera_front,
                  label: 'Calls & Huddles',
                ),
              ],
            ),
          ),

          // User Profile Footer
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.borderDark)),
            ),
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 16,
                  backgroundImage: avatarUrl.isNotEmpty
                      ? NetworkImage(avatarUrl)
                      : null,
                  backgroundColor: appConfig.primaryColor,
                  child: avatarUrl.isEmpty
                      ? Text(
                          user?.name[0] ?? 'A',
                          style: const TextStyle(color: Colors.white),
                        )
                      : null,
                ),
                title: Text(
                  user?.name ?? 'Alex Rivera',
                  style: AppTypography.sectionTitle(
                    context,
                  ).copyWith(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  user?.role ?? 'Lead Architect',
                  style: AppTypography.caption(context),
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.settings_outlined,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                  onPressed: () => provider.setTab(WorkspaceTab.profile),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Text(
        title,
        style: AppTypography.label(
          context,
        ).copyWith(fontSize: 10, letterSpacing: 0.8),
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
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          selected: isSelected,
          selectedTileColor: appConfig.primaryColor.withValues(alpha: 0.15),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderSm),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 0,
          ),
          dense: true,
          leading: Icon(
            isSelected ? selectedIcon : icon,
            size: 18,
            color: isSelected ? appConfig.primaryColor : AppColors.textMuted,
          ),
          title: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
          trailing: badgeCount > 0
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? appConfig.primaryColor
                        : AppColors.surfaceElevated,
                    borderRadius: AppRadius.borderPill,
                  ),
                  child: Text(
                    '$badgeCount',
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
          onTap: () => provider.setTab(tab),
        ),
      ),
    );
  }
}
