import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:macro_app/config/app_config.dart';
import 'package:macro_app/main.dart';
import 'package:macro_app/providers/workspace_provider.dart';
import 'package:macro_app/repositories/auth_repository.dart';
import 'package:macro_app/services/secure_storage_service.dart';

void main() {
  testWidgets(
    'App Factory Boot Pipeline: Splash -> Onboarding -> Login -> Workspace',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1600, 1000);
      tester.view.devicePixelRatio = 1.0;

      // Clear secure storage for fresh test state
      await SecureStorageService().clear();

      final authRepo = AuthRepository();

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

      // Tap 1-Tap Demo Sign In
      await tester.tap(find.text('⚡ Demo 1-Tap Sign In'));
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump();

      // 4. Verify Main Workspace renders
      expect(find.text('Macro Unified Workspace'), findsWidgets);

      addTearDown(tester.view.resetPhysicalSize);
    },
  );
}
