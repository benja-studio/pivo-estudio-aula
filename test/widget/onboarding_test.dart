import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aula/app/theme/theme_provider.dart';
import 'package:aula/core/database/app_database.dart';
import 'package:aula/features/onboarding/presentation/screens/onboarding_screen.dart';

void main() {
  late AppDatabase db;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildTestableWidget() {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MaterialApp(
        home: OnboardingScreen(),
      ),
    );
  }

  testWidgets('Onboarding loads welcome step and validates mandatory fields', (tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Verify Welcome step
    expect(find.text('Bienvenido a Aula'), findsOneWidget);
    expect(find.text('Continuar'), findsOneWidget);

    // Tap Continuar to go to step 2 (Datos del estudiante)
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.text('Cuéntanos sobre tus estudios'), findsOneWidget);

    // Attempting to advance without filling required fields shows inline validation
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.text('Ingresa tu nombre y apellido'), findsOneWidget);
    expect(find.text('Ingresa tu carrera'), findsOneWidget);
    expect(find.text('Ingresa tu facultad o universidad'), findsOneWidget);

    // Fill in required data
    await tester.enterText(find.byType(TextFormField).at(0), 'Sofia Gomez');
    await tester.enterText(find.byType(TextFormField).at(1), 'Medicina');
    await tester.enterText(find.byType(TextFormField).at(2), 'UBA');
    await tester.pumpAndSettle();

    // Now advance to step 3 (Avatar)
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.text('Foto de perfil'), findsOneWidget);
    expect(find.text('SG'), findsOneWidget); // Calculated initials

    // Advance to step 4 (Preferencias)
    await tester.tap(find.text('Continuar con avatar'));
    await tester.pumpAndSettle();

    expect(find.text('Preferencias iniciales'), findsOneWidget);
    expect(find.text('Comenzar en Aula'), findsOneWidget);
  });
}
