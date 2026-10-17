import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aula/core/design_system/components/app_button.dart';
import 'package:aula/core/design_system/components/pressable_scale.dart';

void main() {
  testWidgets('PressableScale reacts to tap and triggers callback', (tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: PressableScale(
              onTap: () => tapped = true,
              child: const Text('Tap Me'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Tap Me'), findsOneWidget);
    await tester.tap(find.text('Tap Me'));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });

  testWidgets('AppButton renders label and responds to interaction', (tester) async {
    bool pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppButton(
              text: 'Aceptar',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Aceptar'), findsOneWidget);
    await tester.tap(find.text('Aceptar'));
    await tester.pumpAndSettle();

    expect(pressed, isTrue);
  });
}
