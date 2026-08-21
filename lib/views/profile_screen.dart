import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../core/auth/auth_repository.dart';
import '../core/google/google_service.dart';
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
    final googleService = Provider.of<GoogleService>(context);

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
                    backgroundColor: appConfig.primaryColor,
                    child: Text(
                      (user?.name ?? 'U').substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Workspace Member',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? 'Unauthenticated',
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
                            color: appConfig.primaryColor.withValues(
                              alpha: 0.2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            (user?.role ?? 'MEMBER').toUpperCase(),
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
            const SizedBox(height: 24),

            // Google Workspace Integration Card (Live Server State)
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
                        Icons.hub_outlined,
                        color: AppColors.info,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Workspace Connections',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),

                      // Live Status Badge
                      _buildGoogleStatusBadge(context, googleService.state),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Connect Google Workspace once to enable Gmail inboxes, Calendar, account discovery, and future workspace integrations.',
                    style: AppTypography.caption(context),
                  ),
                  const SizedBox(height: 16),
                  _buildConnectorTile(
                    context,
                    title: 'Google Workspace',
                    subtitle:
                        'Gmail inboxes, Google Calendar, contacts, and account sync.',
                    icon: Icons.g_mobiledata_rounded,
                    status: googleService.accounts.isEmpty
                        ? 'Not connected'
                        : '${googleService.accounts.length} inbox${googleService.accounts.length == 1 ? '' : 'es'}',
                    statusColor: googleService.accounts.isEmpty
                        ? AppColors.textMuted
                        : AppColors.success,
                    actionLabel: googleService.accounts.isEmpty
                        ? 'Connect Workspace'
                        : 'Connect Another Inbox',
                    onPressed: () => googleService.initiateGoogleOAuth(),
                    appConfig: appConfig,
                  ),
                  const SizedBox(height: 12),
                  _buildConnectorTile(
                    context,
                    title: 'Slack',
                    subtitle:
                        'Channels, threads, messages, and team presence. Adapter pending.',
                    icon: Icons.tag,
                    status: 'Coming next',
                    statusColor: AppColors.textMuted,
                    actionLabel: 'Pending',
                    onPressed: null,
                    appConfig: appConfig,
                  ),
                  const SizedBox(height: 12),
                  _buildConnectorTile(
                    context,
                    title: 'GitHub',
                    subtitle:
                        'Issues, pull requests, commits, and engineering context. Adapter pending.',
                    icon: Icons.code,
                    status: 'Coming next',
                    statusColor: AppColors.textMuted,
                    actionLabel: 'Pending',
                    onPressed: null,
                    appConfig: appConfig,
                  ),
                  const SizedBox(height: 18),

                  if (googleService.isConnected) ...[
                    const Text(
                      'Connected Gmail Inboxes',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...googleService.accounts.map(
                      (account) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildGoogleAccountTile(
                          context,
                          account,
                          googleService,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add_link, size: 16),
                          label: const Text('Connect Another Inbox'),
                          onPressed: () => googleService.initiateGoogleOAuth(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appConfig.primaryColor,
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () async {
                            await googleService.checkConnectionStatus();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Refreshing connected inboxes and calendars...',
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.sync, size: 14),
                          label: const Text(
                            'Refresh Connections',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Text(
                      googleService.errorMessage ??
                          'No Google Workspace account is linked to this Mr Fox session.',
                      style: AppTypography.caption(context),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.open_in_browser, size: 16),
                      label: const Text('Connect Google Workspace'),
                      onPressed: () => googleService.initiateGoogleOAuth(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appConfig.primaryColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Session Security Telemetry Card
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
                  _buildTelemetryRow(
                    'Authentication State',
                    authRepository.isAuthenticated
                        ? 'AUTHENTICATED'
                        : 'UNAUTHENTICATED',
                    authRepository.isAuthenticated
                        ? AppTheme.accentEmerald
                        : AppColors.danger,
                  ),
                  _buildTelemetryRow(
                    'Key Store Provider',
                    'PlatformSecureStorageService',
                    AppTheme.textPrimary,
                  ),
                  _buildTelemetryRow(
                    'Onboarding Status',
                    authRepository.hasCompletedOnboarding
                        ? 'COMPLETED'
                        : 'PENDING',
                    AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.logout, color: AppColors.danger),
                      label: const Text(
                        'Sign Out of Workspace',
                        style: TextStyle(color: AppColors.danger),
                      ),
                      onPressed: () async {
                        await authRepository.logout();
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.danger),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
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

  Widget _buildGoogleStatusBadge(
    BuildContext context,
    GoogleConnectionState state,
  ) {
    Color bg;
    Color fg;
    String text;

    switch (state) {
      case GoogleConnectionState.connected:
        bg = AppColors.success.withValues(alpha: 0.15);
        fg = AppColors.success;
        text = 'Connected';
        break;
      case GoogleConnectionState.linking:
        bg = AppColors.warning.withValues(alpha: 0.15);
        fg = AppColors.warning;
        text = 'Linking...';
        break;
      case GoogleConnectionState.needsReauth:
        bg = AppColors.warning.withValues(alpha: 0.15);
        fg = AppColors.warning;
        text = 'Needs Reauth';
        break;
      case GoogleConnectionState.error:
        bg = AppColors.danger.withValues(alpha: 0.15);
        fg = AppColors.danger;
        text = 'Sync Error';
        break;
      case GoogleConnectionState.notConnected:
        bg = AppColors.surfaceElevated;
        fg = AppColors.textMuted;
        text = 'Not Connected';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: AppTypography.caption(context, color: fg)),
    );
  }

  Widget _buildConnectorTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String status,
    required Color statusColor,
    required String actionLabel,
    required VoidCallback? onPressed,
    required AppConfig appConfig,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 440;
          final iconBox = Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: appConfig.primaryColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: appConfig.primaryColor, size: 22),
          );
          final textContent = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.body(
                  context,
                  color: AppColors.textPrimary,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 3),
              Text(
                status,
                style: AppTypography.caption(context, color: statusColor),
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: AppTypography.caption(context)),
            ],
          );
          final action = OutlinedButton(
            onPressed: onPressed,
            child: Text(actionLabel, style: const TextStyle(fontSize: 12)),
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    iconBox,
                    const SizedBox(width: 12),
                    Expanded(child: textContent),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(width: double.infinity, child: action),
              ],
            );
          }

          return Row(
            children: [
              iconBox,
              const SizedBox(width: 12),
              Expanded(child: textContent),
              const SizedBox(width: 12),
              action,
            ],
          );
        },
      ),
    );
  }

  Widget _buildGoogleAccountTile(
    BuildContext context,
    MacroGoogleAccount account,
    GoogleService googleService,
  ) {
    final statusText = account.needsReauthentication
        ? 'Needs reauth'
        : account.syncActive
        ? 'Sync active'
        : account.syncStatus;
    final statusColor = account.needsReauthentication
        ? AppColors.warning
        : account.syncActive
        ? AppColors.success
        : AppColors.textMuted;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.surfaceElevated,
            backgroundImage:
                account.photoUrl != null && account.photoUrl!.trim().isNotEmpty
                ? NetworkImage(account.photoUrl!.trim())
                : null,
            child: account.photoUrl == null || account.photoUrl!.trim().isEmpty
                ? Text(
                    account.emailAddress.substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: AppColors.textPrimary),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.emailAddress,
                  style: AppTypography.body(
                    context,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  account.primary ? '$statusText • Primary' : statusText,
                  style: AppTypography.caption(context, color: statusColor),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () =>
                googleService.disconnectGoogle(linkId: account.linkId),
            child: const Text(
              'Disconnect',
              style: TextStyle(color: AppColors.danger, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
