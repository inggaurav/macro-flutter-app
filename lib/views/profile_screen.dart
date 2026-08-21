import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../repositories/auth_repository.dart';
import '../design/tokens/app_colors.dart';
import '../design/tokens/app_typography.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  final AppConfig appConfig;
  final AuthRepository authRepository;

  const ProfileScreen({
    super.key,
    required this.appConfig,
    required this.authRepository,
  });

  @override
  Widget build(BuildContext context) {
    final user = authRepository.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Profile & Settings',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage your session and workspace preferences for ${appConfig.workspaceName}.',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),

            // Profile Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderDark),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                      user?.avatarUrl ??
                          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Alex Rivera',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? 'alex@macro.inc',
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: appConfig.primaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            user?.role.toUpperCase() ?? 'LEAD ARCHITECT',
                            style: TextStyle(
                              color: appConfig.primaryColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Google Workspace & Calendar Integration Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.g_mobiledata_rounded,
                        color: AppColors.info,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Google Workspace & Calendar Sync',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Connected',
                          style: AppTypography.caption(
                            context,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Gmail Inbox Sync, Google Calendar Events & Google Drive Document links active.',
                    style: AppTypography.caption(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Session Security Telemetry Card (NO raw JWT token displayed)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderDark),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: AppTheme.accentEmerald,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Session Security & Environment',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildInfoRow(
                    'Session State',
                    'Active & Encrypted',
                    AppTheme.accentEmerald,
                  ),
                  const Divider(height: 20),
                  _buildInfoRow(
                    'Token Storage',
                    'Secure System Keyring',
                    AppTheme.textPrimary,
                  ),
                  const Divider(height: 20),
                  _buildInfoRow(
                    'Environment',
                    appConfig.environment.name.toUpperCase(),
                    AppTheme.primaryIndigo,
                  ),
                  const Divider(height: 20),
                  _buildInfoRow(
                    'API Endpoint',
                    appConfig.apiBaseUrl,
                    AppTheme.textSecondary,
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.accentRose,
                        side: const BorderSide(color: AppTheme.accentRose),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text('Log Out of Workspace'),
                      onPressed: () => authRepository.logout(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
