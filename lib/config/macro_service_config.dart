class MacroServiceConfig {
  final String authHost;
  final String storageHost;
  final String emailHost;
  final String cognitionHost;
  final String notificationHost;
  final String connectionGateway;
  final String contactsHost;
  final String searchHost;
  final String staticFilesHost;
  final String scheduledActionsHost;

  const MacroServiceConfig({
    required this.authHost,
    required this.storageHost,
    required this.emailHost,
    required this.cognitionHost,
    required this.notificationHost,
    required this.connectionGateway,
    required this.contactsHost,
    required this.searchHost,
    required this.staticFilesHost,
    required this.scheduledActionsHost,
  });

  factory MacroServiceConfig.production() {
    const storageHost = String.fromEnvironment(
      'MACRO_STORAGE_HOST',
      defaultValue: 'https://cloud-storage.macro.com',
    );

    return const MacroServiceConfig(
      authHost: String.fromEnvironment(
        'MACRO_AUTH_HOST',
        defaultValue: 'https://auth-service.macro.com',
      ),
      storageHost: storageHost,
      emailHost: String.fromEnvironment(
        'MACRO_EMAIL_HOST',
        defaultValue: 'https://email-service.macro.com',
      ),
      cognitionHost: String.fromEnvironment(
        'MACRO_COGNITION_HOST',
        defaultValue: 'https://document-cognition.macro.com',
      ),
      notificationHost: String.fromEnvironment(
        'MACRO_NOTIFICATION_HOST',
        defaultValue: 'https://notifications.macro.com',
      ),
      connectionGateway: String.fromEnvironment(
        'MACRO_REALTIME_GATEWAY',
        defaultValue: 'wss://connection-gateway.macro.com',
      ),
      contactsHost: String.fromEnvironment(
        'MACRO_CONTACTS_HOST',
        defaultValue: 'https://contacts.macro.com',
      ),
      // Macro serves search/properties from the document-storage host.
      // Keep a separate override for self-hosted deployments, but default it
      // to the verified storage service instead of an invented hostname.
      searchHost: String.fromEnvironment(
        'MACRO_SEARCH_HOST',
        defaultValue: storageHost,
      ),
      staticFilesHost: String.fromEnvironment(
        'MACRO_STATIC_FILES_HOST',
        defaultValue: 'https://static-file-service.macro.com',
      ),
      scheduledActionsHost: String.fromEnvironment(
        'MACRO_SCHEDULED_HOST',
        defaultValue: 'https://agent-schedule.macro.com',
      ),
    );
  }
}
