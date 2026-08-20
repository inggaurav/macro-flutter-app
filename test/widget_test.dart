import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:macro_app/config/app_config.dart';
import 'package:macro_app/main.dart';
import 'package:macro_app/providers/workspace_provider.dart';
import 'package:macro_app/repositories/auth_repository.dart';

void main() {
  testWidgets('App Factory Boot Pipeline: Splash -> Onboarding -> Login -> Workspace', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;

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

    // Advance startup pipeline timer
    await tester.pumpAndSettle(const Duration(milliseconds: 1500));

    // 2. Verify Onboarding Wizard appears on fresh install
    expect(find.text('Unified Communication'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);

    // Tap Skip on Onboarding
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    // 3. Verify Login Screen appears
    expect(find.text('Sign in to Macro Unified Workspace'), findsOneWidget);
    expect(find.text('Continue to Workspace'), findsOneWidget);

    // Tap 1-Tap Demo Sign In
    await tester.tap(find.text('⚡ Demo 1-Tap Sign In'));
    await tester.pumpAndSettle(const Duration(milliseconds: 1000));

    // 4. Verify Main Workspace renders
    expect(find.text('Good morning, Alex 👋'), findsOneWidget);

    addTearDown(tester.view.resetPhysicalSize);
  });
}
