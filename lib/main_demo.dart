import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_config.dart';
import 'core/persistence/local_cache.dart';
import 'core/realtime/realtime_client.dart';
import 'features/chat/chat_repository.dart';
import 'features/chat/controllers/chat_controller.dart';
import 'features/inbox/controllers/inbox_controller.dart';
import 'features/inbox/inbox_repository.dart';
import 'main.dart';
import 'providers/workspace_provider.dart';
import 'repositories/auth_repository.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WorkspaceProvider()),
        ChangeNotifierProvider(create: (_) => AuthRepository()),
        ChangeNotifierProvider(
          create: (_) => ChatController(
            repository: MockChatRepository(),
            cacheStore: SharedPreferencesLocalCacheStore(),
            realtimeClient: MockRealtimeClient(),
          )..loadChannels(),
        ),
        ChangeNotifierProvider(
          create: (_) => InboxController(
            repository: MockInboxRepository(),
            cacheStore: SharedPreferencesLocalCacheStore(),
          )..loadEmails(),
        ),
        Provider.value(value: AppConfig.defaultConfig),
      ],
      child: const MacroApp(),
    ),
  );
}
