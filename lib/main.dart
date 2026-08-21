import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_config.dart';
import 'providers/workspace_provider.dart';
import 'repositories/auth_repository.dart';
import 'theme/app_theme.dart';
import 'views/auth/splash_screen.dart';
import 'views/auth/onboarding_screen.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/signup_screen.dart';
import 'views/auth/forgot_password_screen.dart';
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

import 'features/chat/chat_repository.dart';
import 'features/chat/controllers/chat_controller.dart';
import 'features/inbox/inbox_repository.dart';
import 'features/inbox/controllers/inbox_controller.dart';
import 'core/persistence/local_cache.dart';
import 'core/realtime/realtime_client.dart';

import 'config/macro_service_config.dart';
import 'core/networking/macro_realtime_client.dart';
import 'core/google/google_service.dart';
import 'features/agents/agent_repository.dart';
import 'features/agents/ai_chat_controller.dart';

void main() {
  const useRemoteServices = bool.fromEnvironment(
    'MACRO_USE_REMOTE_SERVICES',
    defaultValue: false,
  );
  final serviceConfig = useRemoteServices
      ? MacroServiceConfig.production()
      : MacroServiceConfig.localDevelopment();
  final authRepo = AuthRepository(config: serviceConfig);
  final realtimeClient = MacroRealtimeClient(
    gatewayUrl: serviceConfig.connectionGateway,
    tokenProvider: () => authRepo.authToken,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WorkspaceProvider()),
        ChangeNotifierProvider.value(value: authRepo),
        ChangeNotifierProvider(
          create: (_) => GoogleService(
            config: serviceConfig,
            tokenProvider: () => authRepo.authToken,
          )..checkConnectionStatus(),
        ),
        ChangeNotifierProvider(
          create: (_) => AiChatController(
            repository: MacroAgentRepository(
              config: serviceConfig,
              tokenProvider: () => authRepo.authToken,
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatController(
            repository: MacroChatRepository(
              config: serviceConfig,
              tokenProvider: () => authRepo.authToken,
            ),
            cacheStore: SharedPreferencesLocalCacheStore(),
            realtimeClient: realtimeClient,
          )..loadChannels(),
        ),
        ChangeNotifierProvider(
          create: (_) => InboxController(
            repository: MacroInboxRepository(
              config: serviceConfig,
              tokenProvider: () => authRepo.authToken,
            ),
            cacheStore: SharedPreferencesLocalCacheStore(),
          )..loadEmails(),
        ),
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
  String _authSubRoute = 'login'; // 'login', 'signup', 'forgot'

  @override
  Widget build(BuildContext context) {
    final appConfig = Provider.of<AppConfig>(context);
    final authRepo = Provider.of<AuthRepository>(context);
    final unreadCount = Provider.of<InboxController>(
      context,
    ).emails.where((e) => e.isUnread).length;

    return MaterialApp(
      title: appConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: !_isAppInitialized
          ? SplashScreen(
              appConfig: appConfig,
              authRepository: authRepo,
              onInitComplete: (result) {
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
          ? _buildAuthSubScreen(appConfig, authRepo)
          : const MacroMainScreen(),
    );
  }

  Widget _buildAuthSubScreen(AppConfig appConfig, AuthRepository authRepo) {
    switch (_authSubRoute) {
      case 'signup':
        return SignupScreen(
          appConfig: appConfig,
          authRepository: authRepo,
          onSignupSuccess: () => setState(() => _authSubRoute = 'login'),
          onNavToLogin: () => setState(() => _authSubRoute = 'login'),
        );
      case 'forgot':
        return ForgotPasswordScreen(
          appConfig: appConfig,
          authRepository: authRepo,
          onBackToLogin: () => setState(() => _authSubRoute = 'login'),
        );
      case 'login':
      default:
        return LoginScreen(
          authRepository: authRepo,
          onLoginSuccess: () {},
          onNavigateToSignup: () => setState(() => _authSubRoute = 'signup'),
          onNavigateToForgotPassword: () =>
              setState(() => _authSubRoute = 'forgot'),
        );
    }
  }
}

class MacroMainScreen extends StatelessWidget {
  const MacroMainScreen({super.key});

  int _getTabIndex(WorkspaceTab tab) {
    switch (tab) {
      case WorkspaceTab.dashboard:
        return 0;
      case WorkspaceTab.inbox:
        return 1;
      case WorkspaceTab.chat:
        return 2;
      case WorkspaceTab.docs:
        return 3;
      case WorkspaceTab.tasks:
        return 4;
      case WorkspaceTab.crm:
        return 5;
      case WorkspaceTab.aiMemory:
        return 6;
      case WorkspaceTab.calls:
        return 7;
      case WorkspaceTab.settings:
      case WorkspaceTab.profile:
      default:
        return 8;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final appConfig = Provider.of<AppConfig>(context);
    final authRepo = Provider.of<AuthRepository>(context);

    return Consumer<WorkspaceProvider>(
      builder: (context, provider, child) {
        if (isMobile) {
          return _buildMobileShell(context, provider, appConfig, authRepo);
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
                        index: _getTabIndex(provider.activeTab),
                        children: [
                          DashboardView(provider: provider),
                          InboxView(provider: provider),
                          ChatView(provider: provider),
                          DocsView(provider: provider),
                          TasksView(provider: provider),
                          CrmView(provider: provider),
                          AiMemoryView(provider: provider),
                          CallRoomView(provider: provider),
                          ProfileScreen(
                            appConfig: appConfig,
                            authRepository: authRepo,
                          ),
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
  Widget _buildMobileShell(
    BuildContext context,
    WorkspaceProvider provider,
    AppConfig appConfig,
    AuthRepository authRepo,
  ) {
    final unreadCount = Provider.of<InboxController>(
      context,
    ).emails.where((e) => e.isUnread).length;
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
          _showMobileMoreSheet(context, provider, appConfig);
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
                color: appConfig.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  appConfig.logoText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              appConfig.appName.split(' ')[0],
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: appConfig.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'AI',
                style: TextStyle(
                  color: appConfig.primaryColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.psychology,
              color: provider.isCopilotDrawerOpen
                  ? appConfig.primaryColor
                  : AppTheme.textSecondary,
            ),
            onPressed: () => provider.toggleCopilotDrawer(),
          ),
        ],
      ),
      body: Stack(
        children: [
          IndexedStack(
            index: _getTabIndex(provider.activeTab),
            children: [
              DashboardView(provider: provider),
              InboxView(provider: provider),
              ChatView(provider: provider),
              DocsView(provider: provider),
              TasksView(provider: provider),
              CrmView(provider: provider),
              AiMemoryView(provider: provider),
              CallRoomView(provider: provider),
              ProfileScreen(appConfig: appConfig, authRepository: authRepo),
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
        selectedItemColor: appConfig.primaryColor,
        unselectedItemColor: AppTheme.textMuted,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: unreadCount > 0
                ? Badge(
                    label: Text('$unreadCount'),
                    child: const Icon(Icons.mail_outline),
                  )
                : const Icon(Icons.mail_outline),
            activeIcon: const Icon(Icons.mail),
            label: 'Inbox',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.check_box_outlined),
            activeIcon: Icon(Icons.check_box),
            label: 'Tasks',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'More',
          ),
        ],
      ),
    );
  }

  void _showMobileMoreSheet(
    BuildContext context,
    WorkspaceProvider provider,
    AppConfig appConfig,
  ) {
    final flags = appConfig.featureFlags;

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
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderDark,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${appConfig.appName} Tools',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _buildMoreTile(
                    context,
                    provider,
                    appConfig,
                    WorkspaceTab.docs,
                    Icons.description_outlined,
                    'Docs & Wiki',
                  ),
                  if (flags['enableCrm'] ?? true)
                    _buildMoreTile(
                      context,
                      provider,
                      appConfig,
                      WorkspaceTab.crm,
                      Icons.pie_chart_outline,
                      'CRM & Deals',
                    ),
                  if (flags['enableAiCopilot'] ?? true)
                    _buildMoreTile(
                      context,
                      provider,
                      appConfig,
                      WorkspaceTab.aiMemory,
                      Icons.auto_awesome_outlined,
                      'AI Memory',
                    ),
                  if (flags['enableCalls'] ?? true)
                    _buildMoreTile(
                      context,
                      provider,
                      appConfig,
                      WorkspaceTab.calls,
                      Icons.videocam_outlined,
                      'Calls & Notes',
                    ),
                  _buildMoreTile(
                    context,
                    provider,
                    appConfig,
                    WorkspaceTab.settings,
                    Icons.person_outline,
                    'Profile',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMoreTile(
    BuildContext context,
    WorkspaceProvider provider,
    AppConfig appConfig,
    WorkspaceTab tab,
    IconData icon,
    String label,
  ) {
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
            Icon(icon, color: appConfig.primaryColor, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
