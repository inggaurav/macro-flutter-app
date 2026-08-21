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

  factory MacroServiceConfig.liveHostinger() {
    return const MacroServiceConfig(
      authHost: 'https://mrfox.hiddenleafagency.com',
      storageHost: 'https://mrfox.hiddenleafagency.com',
      emailHost: 'https://mrfox.hiddenleafagency.com',
      cognitionHost: 'https://mrfox.hiddenleafagency.com',
      notificationHost: 'https://mrfox.hiddenleafagency.com',
      connectionGateway: 'wss://mrfox.hiddenleafagency.com',
      contactsHost: 'https://mrfox.hiddenleafagency.com',
      searchHost: 'https://mrfox.hiddenleafagency.com',
      staticFilesHost: 'https://mrfox.hiddenleafagency.com',
      scheduledActionsHost: 'https://mrfox.hiddenleafagency.com',
    );
  }

  factory MacroServiceConfig.production() {
    return const MacroServiceConfig(
      authHost: String.fromEnvironment(
        'MACRO_AUTH_HOST',
        defaultValue: 'https://auth-service.macro.com',
      ),
      storageHost: String.fromEnvironment(
        'MACRO_STORAGE_HOST',
        defaultValue: 'https://cloud-storage.macro.com',
      ),
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
      searchHost: String.fromEnvironment(
        'MACRO_SEARCH_HOST',
        defaultValue: 'https://properties.macro.com',
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

  factory MacroServiceConfig.localDevelopment() {
    return const MacroServiceConfig(
      authHost: 'http://127.0.0.1:8080',
      storageHost: 'http://127.0.0.1:8081',
      emailHost: 'http://127.0.0.1:8082',
      cognitionHost: 'http://127.0.0.1:8083',
      notificationHost: 'http://127.0.0.1:8084',
      connectionGateway: 'ws://127.0.0.1:8085',
      contactsHost: 'http://127.0.0.1:8086',
      searchHost: 'http://127.0.0.1:8087',
      staticFilesHost: 'http://127.0.0.1:8088',
      scheduledActionsHost: 'http://127.0.0.1:8089',
    );
  }
}
