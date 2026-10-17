import 'package:drift/drift.dart';
import 'package:aula/core/database/app_database.dart';
import 'package:aula/core/database/mappers/database_mappers.dart';
import 'package:aula/core/database/tables/exams_table.dart';
import 'package:aula/features/exams/domain/entities/exam.dart';

part 'exams_dao.g.dart';

@DriftAccessor(tables: [ExamsTable])
class ExamsDao extends DatabaseAccessor<AppDatabase> with _$ExamsDaoMixin {
  ExamsDao(super.db);

  Stream<List<Exam>> watchUpcomingExams() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return (select(examsTable)
          ..where((t) => t.deletedAt.isNull() & t.examDate.isBiggerOrEqualValue(today) & t.status.equals('pending'))
          ..orderBy([(t) => OrderingTerm(expression: t.examDate, mode: OrderingMode.asc)]))
        .watch()
        .map((rows) => rows.map(DatabaseMappers.toExam).toList());
  }

  Stream<List<Exam>> watchOverdueExams() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return (select(examsTable)
          ..where((t) => t.deletedAt.isNull() & t.examDate.isSmallerThanValue(today) & t.status.equals('pending'))
          ..orderBy([(t) => OrderingTerm(expression: t.examDate, mode: OrderingMode.desc)]))
        .watch()
        .map((rows) => rows.map(DatabaseMappers.toExam).toList());
  }

  Stream<List<Exam>> watchExamsBySubject(String subjectId) {
    return (select(examsTable)
          ..where((t) => t.deletedAt.isNull() & t.subjectId.equals(subjectId))
          ..orderBy([(t) => OrderingTerm(expression: t.examDate, mode: OrderingMode.asc)]))
        .watch()
        .map((rows) => rows.map(DatabaseMappers.toExam).toList());
  }

  Stream<List<Exam>> watchAllActiveExams() {
    return (select(examsTable)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm(expression: t.examDate, mode: OrderingMode.asc)]))
        .watch()
        .map((rows) => rows.map(DatabaseMappers.toExam).toList());
  }

  Future<Exam?> getExamById(String id) async {
    final row = await (select(examsTable)..where((t) => t.id.equals(id))).getSingleOrNull();
    return row != null ? DatabaseMappers.toExam(row) : null;
  }

  Future<void> insertExam(Exam exam) async {
    final companion = DatabaseMappers.toExamCompanion(exam);
    await into(examsTable).insert(companion);
  }

  Future<void> updateExam(Exam exam) async {
    final companion = DatabaseMappers.toExamCompanion(exam);
    await (update(examsTable)..where((t) => t.id.equals(exam.id))).write(companion);
  }

  Future<void> softDeleteExam(String id) async {
    await (update(examsTable)..where((t) => t.id.equals(id))).write(
      ExamsTableCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> restoreExam(String id) async {
    await (update(examsTable)..where((t) => t.id.equals(id))).write(
      ExamsTableCompanion(
        deletedAt: const Value(null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Non-blocking conflict check: finds any other exam scheduled overlapping with [candidate]
  Future<List<Exam>> findConflictingExams(Exam candidate) async {
    final sameDayStart = DateTime(candidate.dateTime.year, candidate.dateTime.month, candidate.dateTime.day);
    final sameDayEnd = sameDayStart.add(const Duration(days: 1));

    final rows = await (select(examsTable)
          ..where((t) =>
              t.deletedAt.isNull() &
              t.id.isNotValue(candidate.id) &
              t.examDate.isBiggerOrEqualValue(sameDayStart) &
              t.examDate.isSmallerThanValue(sameDayEnd)))
        .get();

    final exams = rows.map(DatabaseMappers.toExam).toList();
    return exams.where(candidate.conflictsWith).toList();
  }
}
