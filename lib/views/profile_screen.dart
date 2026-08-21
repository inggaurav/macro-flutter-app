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
      body: RefreshIndicator(
        onRefresh: googleService.checkConnectionStatus,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Profile & Connected Services',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage your workspace session, Gmail accounts and Google Calendar access.',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
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
                      _initial(user?.name),
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
                          overflow: TextOverflow.ellipsis,
                        ),
                        if ((user?.email ?? '').isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            user!.email,
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
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
                        size: 26,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Google — Gmail & Calendar',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      _buildGoogleStatusBadge(context, googleService.state),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _connectionDescription(googleService),
                    style: AppTypography.caption(context),
                  ),
                  if (googleService.accounts.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ...googleService.accounts.map(
                      (account) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: account.photoUrl != null
                                  ? NetworkImage(account.photoUrl!)
                                  : null,
                              child: account.photoUrl == null
                                  ? const Icon(Icons.mail_outline, size: 16)
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
                                  Text(
                                    '${account.isPrimary ? 'Primary • ' : ''}${account.syncStatus}${account.needsReauth ? ' • Reauthorization required' : ''}',
                                    style: AppTypography.caption(context),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Disconnect this Gmail account',
                              onPressed: () =>
                                  googleService.disconnectGoogle(account.id),
                              icon: const Icon(
                                Icons.link_off,
                                size: 18,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (googleService.calendars.isNotEmpty) ...[
                    const Divider(color: AppColors.borderDark),
                    Text(
                      '${googleService.calendars.length} Google Calendar${googleService.calendars.length == 1 ? '' : 's'} available${googleService.calendarSyncing ? ' • syncing' : ''}',
                      style: AppTypography.bodySmall(
                        context,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...googleService.calendars.take(4).map(
                      (calendar) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Icon(
                              calendar.isPrimary
                                  ? Icons.calendar_month
                                  : Icons.calendar_today_outlined,
                              size: 16,
                              color: AppColors.info,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${calendar.name} • ${calendar.emailAddress}',
                                style: AppTypography.caption(context),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!calendar.isWritable)
                              Text(
                                'Read only',
                                style: AppTypography.caption(context),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (googleService.state ==
                              GoogleConnectionState.notConnected ||
                          googleService.state == GoogleConnectionState.error ||
                          googleService.state ==
                              GoogleConnectionState.needsReauth)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add_link, size: 16),
                          label: Text(
                            googleService.state ==
                                    GoogleConnectionState.needsReauth
                                ? 'Reconnect Google'
                                : 'Connect Gmail & Calendar',
                          ),
                          onPressed: () =>
                              googleService.initiateGoogleOAuth(
                                includeCalendar: true,
                              ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appConfig.primaryColor,
                          ),
                        ),
                      if (googleService.accounts.isNotEmpty &&
                          !googleService.hasCalendarAccess)
                        OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_month, size: 16),
                          label: const Text('Enable Google Calendar'),
                          onPressed: () =>
                              googleService.initiateGoogleOAuth(
                                includeCalendar: true,
                              ),
                        ),
                      if (googleService.accounts.isNotEmpty)
                        OutlinedButton.icon(
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add another Gmail'),
                          onPressed: () =>
                              googleService.initiateGoogleOAuth(
                                includeCalendar: true,
                              ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
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
                        'Session Security',
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
                    'Authentication',
                    authRepository.isAuthenticated
                        ? 'AUTHENTICATED'
                        : 'UNAUTHENTICATED',
                    authRepository.isAuthenticated
                        ? AppTheme.accentEmerald
                        : AppColors.danger,
                  ),
                  _buildTelemetryRow(
                    'Credential storage',
                    'Platform secure storage',
                    AppTheme.textPrimary,
                  ),
                  _buildTelemetryRow(
                    'Refresh session',
                    authRepository.refreshToken != null ? 'AVAILABLE' : 'N/A',
                    AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.logout, color: AppColors.danger),
                      label: const Text(
                        'Sign Out',
                        style: TextStyle(color: AppColors.danger),
                      ),
                      onPressed: authRepository.logout,
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

  String _initial(String? name) {
    final value = name?.trim() ?? '';
    return value.isEmpty ? 'U' : value.substring(0, 1).toUpperCase();
  }

  String _connectionDescription(GoogleService service) {
    switch (service.state) {
      case GoogleConnectionState.connected:
        return service.hasCalendarAccess
            ? 'Gmail is connected and Google Calendar access is active.'
            : 'Gmail is connected. Enable Calendar to sync events and meetings.';
      case GoogleConnectionState.linking:
        return 'Waiting for Google authorization to complete.';
      case GoogleConnectionState.needsReauth:
        return 'Google revoked or expired the grant. Reconnect to resume sync.';
      case GoogleConnectionState.error:
        return service.errorMessage ?? 'Google connection could not be verified.';
      case GoogleConnectionState.notConnected:
        return 'Connect a Google account to sync Gmail, Contacts and Calendar through the Macro backend.';
    }
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
        text = 'Connecting';
        break;
      case GoogleConnectionState.needsReauth:
        bg = AppColors.warning.withValues(alpha: 0.15);
        fg = AppColors.warning;
        text = 'Reconnect';
        break;
      case GoogleConnectionState.error:
        bg = AppColors.danger.withValues(alpha: 0.15);
        fg = AppColors.danger;
        text = 'Error';
        break;
      case GoogleConnectionState.notConnected:
        bg = AppColors.surfaceElevated;
        fg = AppColors.textMuted;
        text = 'Not connected';
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

  Widget _buildTelemetryRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: valueColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
