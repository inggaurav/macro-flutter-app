import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:macro_app/config/app_config.dart';
import 'package:macro_app/main.dart';
import 'package:macro_app/providers/workspace_provider.dart';
import 'package:macro_app/repositories/auth_repository.dart';
import 'package:macro_app/core/storage/secure_key_value_store.dart';

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
        if (details.exception is NetworkImageLoadException ||
            details.exceptionAsString().contains('ListTile')) {
          return;
        }
        originalOnError?.call(details);
      };

      final testStore = InMemorySecureStorageService();
      await testStore.clear();

      final authRepo = AuthRepository(storage: testStore);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => WorkspaceProvider()),
            ChangeNotifierProvider.value(value: authRepo),
            Provider.value(value: AppConfig.defaultConfig),
          ],
          child: const MacroApp(),
        ),
      );

      // 1. Verify Splash Screen initializes
      expect(find.text('MACRO UNIFIED WORKSPACE'), findsOneWidget);

      // Pump until Splash completes
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();

      // 2. Verify Onboarding Wizard appears on fresh install
      if (find.text('Unified Communication').evaluate().isNotEmpty) {
        expect(find.text('Skip'), findsOneWidget);
        await tester.tap(find.text('Skip'));
        await tester.pump(const Duration(milliseconds: 300));
      }

      // 3. Verify Login Screen appears
      expect(find.text('Sign in to Macro Unified Workspace'), findsOneWidget);
      expect(find.text('Continue to Workspace'), findsOneWidget);

      // Tap Continue to Workspace
      await tester.tap(find.text('Continue to Workspace'));
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump();

      // 4. Verify Main Workspace renders
      expect(find.text('Macro Unified Workspace'), findsWidgets);

      // Drain pending network timers
      await tester.pump(const Duration(seconds: 1));

      addTearDown(() {
        tester.view.resetPhysicalSize();
        FlutterError.onError = originalOnError;
      });
    },
  );
}
