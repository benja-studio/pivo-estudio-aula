import 'package:drift/drift.dart';
import 'package:aula/core/database/app_database.dart';
import 'package:aula/core/database/mappers/database_mappers.dart';
import 'package:aula/core/database/tables/grades_table.dart';
import 'package:aula/features/grades/domain/entities/grade_entry.dart';

part 'grades_dao.g.dart';

@DriftAccessor(tables: [GradesTable])
class GradesDao extends DatabaseAccessor<AppDatabase> with _$GradesDaoMixin {
  GradesDao(super.db);

  Stream<List<GradeEntry>> watchGradesBySubject(String subjectId) {
    return (select(gradesTable)
          ..where((t) => t.deletedAt.isNull() & t.subjectId.equals(subjectId))
          ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
        .watch()
        .map((rows) => rows.map(DatabaseMappers.toGradeEntry).toList());
  }

  Stream<List<GradeEntry>> watchAllActiveGrades() {
    return (select(gradesTable)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.asc)]))
        .watch()
        .map((rows) => rows.map(DatabaseMappers.toGradeEntry).toList());
  }

  Future<List<GradeEntry>> getAllActiveGrades() async {
    final rows = await (select(gradesTable)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.asc)]))
        .get();
    return rows.map(DatabaseMappers.toGradeEntry).toList();
  }

  Future<GradeEntry?> getGradeByExamId(String examId) async {
    final row = await (select(gradesTable)
          ..where((t) => t.deletedAt.isNull() & t.examId.equals(examId)))
        .getSingleOrNull();
    return row != null ? DatabaseMappers.toGradeEntry(row) : null;
  }

  Future<void> insertGrade(GradeEntry grade) async {
    final companion = DatabaseMappers.toGradeEntryCompanion(grade);
    await into(gradesTable).insert(companion);
  }

  Future<void> updateGrade(GradeEntry grade) async {
    final companion = DatabaseMappers.toGradeEntryCompanion(grade);
    await (update(gradesTable)..where((t) => t.id.equals(grade.id))).write(companion);
  }

  Future<void> softDeleteGrade(String id) async {
    await (update(gradesTable)..where((t) => t.id.equals(id))).write(
      GradesTableCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> restoreGrade(String id) async {
    await (update(gradesTable)..where((t) => t.id.equals(id))).write(
      GradesTableCompanion(
        deletedAt: const Value(null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
