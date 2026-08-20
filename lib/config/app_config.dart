class AppConfig {
  final String appName;
  final String workspaceName;
  final String apiBaseUrl;
  final String mcpServerEndpoint;
  final String version;
  final bool enableRealtimeSync;

  const AppConfig({
    required this.appName,
    required this.workspaceName,
    required this.apiBaseUrl,
    required this.mcpServerEndpoint,
    required this.version,
    this.enableRealtimeSync = true,
  });

  static const AppConfig defaultConfig = AppConfig(
    appName: 'Macro Unified Workspace',
    workspaceName: 'Macro Inc.',
    apiBaseUrl: 'https://api.macro.workspace/v1',
    mcpServerEndpoint: 'wss://mcp.macro.workspace/ws',
    version: '1.0.0+1',
  );
}
