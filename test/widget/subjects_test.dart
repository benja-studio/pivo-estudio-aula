import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aula/features/subjects/data/repositories/subjects_repository_impl.dart';
import 'package:aula/features/subjects/domain/entities/subject.dart';
import 'package:aula/features/subjects/presentation/screens/subjects_list_screen.dart';
import 'package:aula/features/subjects/presentation/widgets/subject_card.dart';

void main() {
  testWidgets('SubjectsListScreen displays EmptyState when no subjects exist', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeSubjectsProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: const MaterialApp(
          home: SubjectsListScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('No tienes materias agregadas'), findsOneWidget);
    expect(find.text('Nueva'), findsOneWidget);
  });

  testWidgets('SubjectsListScreen displays SubjectCard and filters by status', (tester) async {
    final now = DateTime.now();
    final subjectTaking = Subject(
      id: 'sub-test-1',
      name: 'Probabilidad y Estadística',
      colorValue: 0xFF3B82F6,
      iconName: 'calculate',
      status: SubjectStatus.taking,
      professor: 'Ing. Gauss',
      createdAt: now,
      updatedAt: now,
    );
    final subjectPassed = Subject(
      id: 'sub-test-2',
      name: 'Álgebra II',
      colorValue: 0xFF10B981,
      iconName: 'book',
      status: SubjectStatus.passed,
      professor: 'Dra. Noether',
      createdAt: now,
      updatedAt: now,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeSubjectsProvider.overrideWith((ref) => Stream.value([subjectTaking, subjectPassed])),
        ],
        child: const MaterialApp(
          home: SubjectsListScreen(),
        ),
      ),
    );
    await tester.pump();

    // Both subjects displayed under "Todas"
    expect(find.byType(SubjectCard), findsNWidgets(2));
    expect(find.text('Probabilidad y Estadística'), findsOneWidget);
    expect(find.text('Álgebra II'), findsOneWidget);

    // Filter by "Aprobadas"
    await tester.tap(find.text('Aprobadas'));
    await tester.pump();

    expect(find.byType(SubjectCard), findsOneWidget);
    expect(find.text('Álgebra II'), findsOneWidget);
    expect(find.text('Probabilidad y Estadística'), findsNothing);
  });
}
