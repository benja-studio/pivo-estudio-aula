import 'package:drift/drift.dart';
import 'package:aula/core/database/tables/exams_table.dart';

@DataClassName('ReminderRuleRow')
class RemindersTable extends Table {
  TextColumn get id => text()();
  TextColumn get examId => text().references(
        ExamsTable,
        #id,
        onDelete: KeyAction.cascade,
      )();
  DateTimeColumn get triggerTime => dateTime()();
  BoolColumn get isDelivered => boolean().withDefault(const Constant(false))();
  BoolColumn get isExact => boolean().withDefault(const Constant(false))();
  TextColumn get notificationTitle => text()();
  TextColumn get notificationBody => text()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
