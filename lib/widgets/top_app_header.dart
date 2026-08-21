import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../design/tokens/app_colors.dart';
import '../design/tokens/app_typography.dart';
import '../providers/workspace_provider.dart';
import '../theme/app_theme.dart';

class TopAppHeader extends StatelessWidget {
  final WorkspaceProvider provider;

  const TopAppHeader({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final appConfig = Provider.of<AppConfig>(context);

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(bottom: BorderSide(color: AppTheme.borderDark)),
      ),
      child: Row(
        children: [
          // Search Input with @-mention prompt
          Expanded(
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppTheme.bgDark,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.borderDark),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 18, color: AppTheme.textMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Search ${appConfig.workspaceName} or type @ to link Docs, Deals, Tasks, Emails...',
                        hintStyle: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLightDark,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Ctrl K',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 16),

          // AI Model Switcher Dropdown
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLightDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.borderDark),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  size: 16,
                  color: AppTheme.accentPurple,
                ),
                const SizedBox(width: 8),
                Text(
                  'Macro Cognition AI',
                  style: AppTypography.caption(
                    context,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // AI Copilot Toggle Button
          InkWell(
            onTap: () => provider.toggleCopilotDrawer(),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: provider.isCopilotDrawerOpen
                    ? AppTheme.primaryIndigo
                    : AppTheme.primaryIndigo.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: provider.isCopilotDrawerOpen
                      ? AppTheme.primaryIndigo
                      : AppTheme.primaryIndigo.withOpacity(0.4),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.psychology,
                    size: 18,
                    color: provider.isCopilotDrawerOpen
                        ? Colors.white
                        : AppTheme.primaryIndigo,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'AI Copilot',
                    style: TextStyle(
                      color: provider.isCopilotDrawerOpen
                          ? Colors.white
                          : AppTheme.primaryIndigo,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
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
