import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:macro_app/main.dart';
import 'package:macro_app/providers/workspace_provider.dart';

void main() {
  testWidgets('MacroApp renders successfully on desktop viewport', (WidgetTester tester) async {
    // Set desktop screen size for testing layout
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => WorkspaceProvider(),
        child: const MacroApp(),
      ),
    );

    // Verify Macro Workspace Header & Telemetry is displayed
    expect(find.text('Macro Workspace'), findsOneWidget);
    expect(find.text('Good morning, Alex 👋'), findsOneWidget);
    expect(find.text('AI Shared Team Memory Daily Synthesis'), findsOneWidget);

    addTearDown(tester.view.resetPhysicalSize);
  });
}
