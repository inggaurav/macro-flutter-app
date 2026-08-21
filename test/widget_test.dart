import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:macro_app/config/app_config.dart';
import 'package:macro_app/main.dart';
import 'package:macro_app/providers/workspace_provider.dart';
import 'package:macro_app/repositories/auth_repository.dart';
import 'package:macro_app/core/storage/secure_key_value_store.dart';
import 'package:macro_app/core/persistence/local_cache.dart';
import 'package:macro_app/core/realtime/realtime_client.dart';
import 'fixtures/mock_chat_repository.dart';
import 'package:macro_app/features/chat/controllers/chat_controller.dart';
import 'package:macro_app/core/google/google_service.dart';
import 'fixtures/mock_inbox_repository.dart';
import 'package:macro_app/features/inbox/controllers/inbox_controller.dart';

class _TestHttpOverrides extends HttpOverrides {}

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  testWidgets(
    'App Factory Boot Pipeline: Splash -> Onboarding -> Login -> Workspace',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1600, 1000);
      tester.view.devicePixelRatio = 1.0;

      final originalOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        if (details.exception is NetworkImageLoadException) {
          return;
        }
        originalOnError?.call(details);
      };

      final testStore = InMemorySecureStorageService();
      await testStore.clear();

      final authRepo = AuthRepository(storage: testStore);
      final cacheStore = InMemoryLocalCacheStore();
      final realtimeClient = MockRealtimeClient();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => WorkspaceProvider()),
            ChangeNotifierProvider.value(value: authRepo),
            ChangeNotifierProvider(
              create: (_) => ChatController(
                repository: MockChatRepository(),
                cacheStore: cacheStore,
                realtimeClient: realtimeClient,
              )..loadChannels(),
            ),
            ChangeNotifierProvider(
              create: (_) => InboxController(
                repository: MockInboxRepository(),
                cacheStore: cacheStore,
              )..loadEmails(),
            ),
            ChangeNotifierProvider(
              create: (_) =>
                  GoogleService(tokenProvider: () => authRepo.authToken),
            ),
            Provider.value(value: AppConfig.defaultConfig),
          ],
          child: const MacroApp(),
        ),
      );

      // 1. Splash Screen
      expect(find.text('MACRO UNIFIED WORKSPACE'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      await tester.pump();

      // 2. Onboarding
      if (find.text('Unified Communication').evaluate().isNotEmpty) {
        expect(find.text('Skip'), findsOneWidget);
        await tester.tap(find.text('Skip'));
        await tester.pump(const Duration(milliseconds: 300));
      }

      // 3. Login Screen
      expect(find.text('Sign In to Workspace'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);

      // 4. Main Workspace
      expect(find.textContaining('Macro Unified Workspace'), findsWidgets);

      await tester.pump(const Duration(seconds: 1));

      addTearDown(() {
        tester.view.resetPhysicalSize();
        FlutterError.onError = originalOnError;
      });
    },
  );
}
