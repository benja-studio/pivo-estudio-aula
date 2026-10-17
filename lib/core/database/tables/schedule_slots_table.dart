import 'package:drift/drift.dart';
import 'package:aula/core/database/tables/subjects_table.dart';

@DataClassName('ScheduleSlotRow')
class ScheduleSlotsTable extends Table {
  TextColumn get id => text()();
  TextColumn get subjectId => text().references(
        SubjectsTable,
        #id,
        onDelete: KeyAction.cascade,
      )();
  IntColumn get dayOfWeek => integer()(); // 1 = Monday, 7 = Sunday
  TextColumn get startTime => text()(); // "HH:mm"
  TextColumn get endTime => text()(); // "HH:mm"
  TextColumn get classroom => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
