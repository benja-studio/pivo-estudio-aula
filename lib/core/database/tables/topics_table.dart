import 'package:drift/drift.dart';
import 'package:aula/core/database/tables/exams_table.dart';
import 'package:aula/core/database/tables/subjects_table.dart';

@DataClassName('TopicRow')
class TopicsTable extends Table {
  TextColumn get id => text()();
  TextColumn get subjectId => text().references(
        SubjectsTable,
        #id,
        onDelete: KeyAction.cascade,
      )();
  TextColumn get examId => text().nullable().references(
        ExamsTable,
        #id,
        onDelete: KeyAction.setNull,
      )();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get notes => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('notStarted'))(); // notStarted, studying, reviewed, mastered
  TextColumn get priority => text().withDefault(const Constant('medium'))(); // low, medium, high
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
