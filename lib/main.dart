import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_config.dart';
import 'providers/workspace_provider.dart';
import 'repositories/auth_repository.dart';
import 'theme/app_theme.dart';
import 'views/auth/splash_screen.dart';
import 'views/auth/onboarding_screen.dart';
import 'views/auth/login_screen.dart';
import 'views/profile_screen.dart';
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
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WorkspaceProvider()),
        ChangeNotifierProvider(create: (_) => AuthRepository()),
        Provider.value(value: AppConfig.defaultConfig),
      ],
      child: const MacroApp(),
    ),
  );
}

class MacroApp extends StatefulWidget {
  const MacroApp({super.key});

  @override
  State<MacroApp> createState() => _MacroAppState();
}

class _MacroAppState extends State<MacroApp> {
  bool _isAppInitialized = false;

  @override
  Widget build(BuildContext context) {
    final appConfig = Provider.of<AppConfig>(context);
    final authRepo = Provider.of<AuthRepository>(context);

    return MaterialApp(
      title: appConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: !_isAppInitialized
          ? SplashScreen(
              appConfig: appConfig,
              authRepository: authRepo,
              onInitComplete: () {
                setState(() {
                  _isAppInitialized = true;
                });
              },
            )
          : !authRepo.hasCompletedOnboarding
              ? OnboardingScreen(
                  appConfig: appConfig,
                  onOnboardingComplete: () {
                    authRepo.completeOnboarding();
                  },
                )
              : !authRepo.isAuthenticated
                  ? LoginScreen(
                      authRepository: authRepo,
                      onLoginSuccess: () {},
                    )
                  : const MacroMainScreen(),
    );
  }
}

class MacroMainScreen extends StatelessWidget {
  const MacroMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final authRepo = Provider.of<AuthRepository>(context);

    return Consumer<WorkspaceProvider>(
      builder: (context, provider, child) {
        if (isMobile) {
          return _buildMobileShell(context, provider, authRepo);
        }

        // Desktop Widescreen Layout
        return Scaffold(
          backgroundColor: AppTheme.bgDark,
          body: Row(
            children: [
              SidebarNavigation(provider: provider),
              Expanded(
                child: Column(
                  children: [
                    TopAppHeader(provider: provider),
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
                          ProfileScreen(authRepository: authRepo),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (provider.isCopilotDrawerOpen)
                AiCopilotDrawer(provider: provider),
            ],
          ),
        );
      },
    );
  }

  // Native Mobile Shell with Top AppBar and Bottom Navigation Bar
  Widget _buildMobileShell(BuildContext context, WorkspaceProvider provider, AuthRepository authRepo) {
    int getBottomIndex() {
      switch (provider.activeTab) {
        case WorkspaceTab.dashboard:
          return 0;
        case WorkspaceTab.inbox:
          return 1;
        case WorkspaceTab.chat:
          return 2;
        case WorkspaceTab.tasks:
          return 3;
        default:
          return 4;
      }
    }

    void setBottomIndex(int index) {
      switch (index) {
        case 0:
          provider.setTab(WorkspaceTab.dashboard);
          break;
        case 1:
          provider.setTab(WorkspaceTab.inbox);
          break;
        case 2:
          provider.setTab(WorkspaceTab.chat);
          break;
        case 3:
          provider.setTab(WorkspaceTab.tasks);
          break;
        case 4:
          _showMobileMoreSheet(context, provider);
          break;
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceDark,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppTheme.primaryIndigo,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('M', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Macro',
              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primaryIndigo.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                provider.activeAiModel.split(' ')[0],
                style: const TextStyle(color: AppTheme.primaryIndigo, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.psychology,
              color: provider.isCopilotDrawerOpen ? AppTheme.primaryIndigo : AppTheme.textSecondary,
            ),
            onPressed: () => provider.toggleCopilotDrawer(),
          ),
        ],
      ),
      body: Stack(
        children: [
          IndexedStack(
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
              ProfileScreen(authRepository: authRepo),
            ],
          ),

          // Mobile Copilot Drawer Overlay
          if (provider.isCopilotDrawerOpen)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: AiCopilotDrawer(provider: provider),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: getBottomIndex(),
        onTap: setBottomIndex,
        backgroundColor: AppTheme.surfaceDark,
        selectedItemColor: AppTheme.primaryIndigo,
        unselectedItemColor: AppTheme.textMuted,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('${provider.emails.where((e) => e.isUnread).length}'),
              child: const Icon(Icons.mail_outline),
            ),
            activeIcon: const Icon(Icons.mail),
            label: 'Inbox',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: 'Chat'),
          const BottomNavigationBarItem(icon: Icon(Icons.check_box_outlined), activeIcon: Icon(Icons.check_box), label: 'Tasks'),
          const BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'More'),
        ],
      ),
    );
  }

  void _showMobileMoreSheet(BuildContext context, WorkspaceProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.borderDark, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              const Text('Macro Workspace Tools', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _buildMoreTile(context, provider, WorkspaceTab.docs, Icons.description_outlined, 'Docs & Wiki'),
                  _buildMoreTile(context, provider, WorkspaceTab.crm, Icons.pie_chart_outline, 'CRM & Deals'),
                  _buildMoreTile(context, provider, WorkspaceTab.aiMemory, Icons.auto_awesome_outlined, 'AI Memory'),
                  _buildMoreTile(context, provider, WorkspaceTab.calls, Icons.videocam_outlined, 'Calls & Notes'),
                  _buildMoreTile(context, provider, WorkspaceTab.settings, Icons.person_outline, 'Profile'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMoreTile(BuildContext context, WorkspaceProvider provider, WorkspaceTab tab, IconData icon, String label) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        provider.setTab(tab);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceLightDark,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.borderDark),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.primaryIndigo, size: 24),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 11, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
