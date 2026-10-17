import 'package:drift/drift.dart';
import 'package:aula/core/database/app_database.dart';
import 'package:aula/core/database/mappers/database_mappers.dart';
import 'package:aula/core/database/tables/schedule_slots_table.dart';
import 'package:aula/core/database/tables/subjects_table.dart';
import 'package:aula/features/subjects/domain/entities/schedule_slot.dart';
import 'package:aula/features/subjects/domain/entities/subject.dart';

part 'subjects_dao.g.dart';

@DriftAccessor(tables: [SubjectsTable, ScheduleSlotsTable])
class SubjectsDao extends DatabaseAccessor<AppDatabase> with _$SubjectsDaoMixin {
  SubjectsDao(super.db);

  Stream<List<Subject>> watchActiveSubjects() {
    return (select(subjectsTable)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc)]))
        .watch()
        .map((rows) => rows.map(DatabaseMappers.toSubject).toList());
  }

  Future<List<Subject>> getAllActiveSubjects() async {
    final rows = await (select(subjectsTable)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc)]))
        .get();
    return rows.map(DatabaseMappers.toSubject).toList();
  }

  Future<Subject?> getSubjectById(String id) async {
    final row = await (select(subjectsTable)..where((t) => t.id.equals(id))).getSingleOrNull();
    return row != null ? DatabaseMappers.toSubject(row) : null;
  }

  Future<void> insertSubject(Subject subject) async {
    final companion = DatabaseMappers.toSubjectCompanion(subject);
    await into(subjectsTable).insert(companion);
  }

  Future<void> updateSubject(Subject subject) async {
    final companion = DatabaseMappers.toSubjectCompanion(subject);
    await (update(subjectsTable)..where((t) => t.id.equals(subject.id))).write(companion);
  }

  Future<void> softDeleteSubject(String id) async {
    await (update(subjectsTable)..where((t) => t.id.equals(id))).write(
      SubjectsTableCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> restoreSubject(String id) async {
    await (update(subjectsTable)..where((t) => t.id.equals(id))).write(
      SubjectsTableCompanion(
        deletedAt: const Value(null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // Schedule Slots
  Future<List<ScheduleSlot>> getScheduleSlots(String subjectId) async {
    final rows = await (select(scheduleSlotsTable)
          ..where((t) => t.subjectId.equals(subjectId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.dayOfWeek, mode: OrderingMode.asc),
            (t) => OrderingTerm(expression: t.startTime, mode: OrderingMode.asc),
          ]))
        .get();
    return rows.map(DatabaseMappers.toScheduleSlot).toList();
  }

  Future<void> setScheduleSlots(String subjectId, List<ScheduleSlot> slots) async {
    await transaction(() async {
      await (delete(scheduleSlotsTable)..where((t) => t.subjectId.equals(subjectId))).go();
      for (final slot in slots) {
        await into(scheduleSlotsTable).insert(DatabaseMappers.toScheduleSlotCompanion(slot));
      }
    });
  }
}
