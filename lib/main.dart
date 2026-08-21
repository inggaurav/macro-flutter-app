import 'dart:async';

import 'package:app_links/app_links.dart';
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

import 'config/macro_service_config.dart';
import 'core/networking/macro_realtime_client.dart';
import 'core/google/google_service.dart';
import 'features/agents/agent_repository.dart';
import 'features/agents/ai_chat_controller.dart';

void main() {
  const useRemoteServices = bool.fromEnvironment(
    'MACRO_USE_REMOTE_SERVICES',
    defaultValue: true,
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
        Provider.value(value: serviceConfig),
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
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  bool _linksInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_linksInitialized) return;
    _linksInitialized = true;

    final authRepo = Provider.of<AuthRepository>(context, listen: false);
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        authRepo.redeemMobileSessionUri(uri);
      }
    });
    _linkSubscription = _appLinks.uriLinkStream.listen(
      authRepo.redeemMobileSessionUri,
    );
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

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
        return 8;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WorkspaceProvider>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        if (isMobile) {
          return Scaffold(
            backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
            body: SafeArea(
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
                    appConfig: AppConfig.defaultConfig,
                    authRepository: Provider.of<AuthRepository>(
                      context,
                      listen: false,
                    ),
                  ),
                ],
              ),
            ),
            drawer: AiCopilotDrawer(provider: provider),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _getTabIndex(provider.activeTab).clamp(0, 4),
              onDestinationSelected: (index) {
                switch (index) {
                  case 0:
                    provider.setActiveTab('dashboard');
                    break;
                  case 1:
                    provider.setActiveTab('inbox');
                    break;
                  case 2:
                    provider.setActiveTab('chat');
                    break;
                  case 3:
                    provider.setActiveTab('docs');
                    break;
                  case 4:
                    provider.setActiveTab('tasks');
                    break;
                }
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.inbox_outlined),
                  selectedIcon: Icon(Icons.inbox),
                  label: 'Inbox',
                ),
                NavigationDestination(
                  icon: Icon(Icons.chat_bubble_outline),
                  selectedIcon: Icon(Icons.chat_bubble),
                  label: 'Chat',
                ),
                NavigationDestination(
                  icon: Icon(Icons.description_outlined),
                  selectedIcon: Icon(Icons.description),
                  label: 'Docs',
                ),
                NavigationDestination(
                  icon: Icon(Icons.check_box_outlined),
                  selectedIcon: Icon(Icons.check_box),
                  label: 'Tasks',
                ),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
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
                            appConfig: AppConfig.defaultConfig,
                            authRepository: Provider.of<AuthRepository>(
                              context,
                              listen: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          endDrawer: AiCopilotDrawer(provider: provider),
        );
      },
    );
  }
}
