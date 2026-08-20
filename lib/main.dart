import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/workspace_provider.dart';
import 'theme/app_theme.dart';
import 'widgets/sidebar_navigation.dart';
import 'widgets/top_app_header.dart';
import 'widgets/ai_copilot_drawer.dart';
import 'views/dashboard_view.dart';
import 'views/inbox_view.dart';
import 'views/chat_view.dart';
import 'views/docs_view.dart';
import 'views/tasks_view.dart';
import 'views/crm_view.dart';
import 'views/ai_memory_view.dart';
import 'views/call_room_view.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => WorkspaceProvider(),
      child: const MacroApp(),
    ),
  );
}

class MacroApp extends StatelessWidget {
  const MacroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Macro Unified Workspace',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MacroMainScreen(),
    );
  }
}

class MacroMainScreen extends StatelessWidget {
  const MacroMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkspaceProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: AppTheme.bgDark,
          body: Row(
            children: [
              // Left Workspace Sidebar Navigation
              SidebarNavigation(provider: provider),

              // Main Workspace Content Area
              Expanded(
                child: Column(
                  children: [
                    // Top App Search & AI Model Selector Header
                    TopAppHeader(provider: provider),

                    // Active Tab View
                    Expanded(
                      child: IndexedStack(
                        index: provider.activeTab.index,
                        children: [
                          DashboardView(provider: provider),
                          InboxView(provider: provider),
                          ChatView(provider: provider),
                          DocsView(provider: provider),
                          TasksView(provider: provider),
                          CrmView(provider: provider),
                          AiMemoryView(provider: provider),
                          CallRoomView(provider: provider),
                          _buildSettingsPlaceholder(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Right AI Copilot Drawer (Animated Toggle)
              if (provider.isCopilotDrawerOpen)
                AiCopilotDrawer(provider: provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsPlaceholder() {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.settings, size: 48, color: AppTheme.primaryIndigo),
            SizedBox(height: 16),
            Text(
              'Macro Settings & API Keys Configuration',
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Manage OpenAI, Anthropic & Google Gemini API keys, MCP integration endpoints, and team roles.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
