import 'package:flutter/material.dart';

enum AppEnvironment { dev, staging, prod }

class OnboardingPageInfo {
  final String title;
  final String description;
  final IconData icon;

  const OnboardingPageInfo({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class AppConfig {
  final String appName;
  final String workspaceName;
  final String packageName;
  final String logoText;
  final Color primaryColor;
  final Color accentColor;
  final AppEnvironment environment;
  final String apiBaseUrl;
  final String mcpServerEndpoint;
  final String version;
  final Map<String, bool> featureFlags;
  final List<OnboardingPageInfo> onboardingPages;

  const AppConfig({
    required this.appName,
    required this.workspaceName,
    required this.packageName,
    required this.logoText,
    required this.primaryColor,
    required this.accentColor,
    required this.environment,
    required this.apiBaseUrl,
    required this.mcpServerEndpoint,
    required this.version,
    required this.featureFlags,
    required this.onboardingPages,
  });

  static const AppConfig defaultConfig = AppConfig(
    appName: 'Macro Unified Workspace',
    workspaceName: 'Macro Inc.',
    packageName: 'com.macro.workspace',
    logoText: 'M',
    primaryColor: Color(0xFF6366F1), // Indigo
    accentColor: Color(0xFFA855F7),  // Purple
    environment: AppEnvironment.prod,
    apiBaseUrl: 'https://api.macro.workspace/v1',
    mcpServerEndpoint: 'wss://mcp.macro.workspace/ws',
    version: '1.0.0+1',
    featureFlags: {
      'enableAiCopilot': true,
      'enableCrm': true,
      'enableCalls': true,
      'enableCrdtSync': true,
      'enableMcpSwarm': true,
    },
    onboardingPages: [
      OnboardingPageInfo(
        title: 'Unified Communication',
        description: 'Email, channels, and direct messages in a single collaborative stream.',
        icon: Icons.chat_bubble_outline,
      ),
      OnboardingPageInfo(
        title: 'AI Shared Memory',
        description: 'Automatic knowledge synthesis across team conversations, PRs, and CRM deals.',
        icon: Icons.auto_awesome_outlined,
      ),
      OnboardingPageInfo(
        title: 'Real-time CRDT Docs & Tasks',
        description: 'Live document collaboration and engineering Kanban boards linked to customer data.',
        icon: Icons.description_outlined,
      ),
    ],
  );
}
