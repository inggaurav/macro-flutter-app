import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:macro_app/config/app_config.dart';
import 'package:macro_app/main.dart';
import 'package:macro_app/providers/workspace_provider.dart';
import 'package:macro_app/repositories/auth_repository.dart';

void main() {
  testWidgets('MacroApp renders splash and boots main screen successfully', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => WorkspaceProvider()),
          ChangeNotifierProvider(create: (_) => AuthRepository()),
          Provider.value(value: AppConfig.defaultConfig),
        ],
        child: const MacroApp(),
      ),
    );

    // Verify Splash Screen renders
    expect(find.text('MACRO UNIFIED WORKSPACE'), findsOneWidget);

    // Advance splash screen timer & initialization pipeline
    await tester.pumpAndSettle(const Duration(milliseconds: 1500));

    // Verify Main Screen renders
    expect(find.text('Macro Workspace'), findsOneWidget);
    expect(find.text('Good morning, Alex 👋'), findsOneWidget);

    addTearDown(tester.view.resetPhysicalSize);
  });
}
