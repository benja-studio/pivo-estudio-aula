import 'package:drift/drift.dart';
import 'package:aula/core/database/tables/exams_table.dart';
import 'package:aula/core/database/tables/subjects_table.dart';

@DataClassName('GradeRow')
class GradesTable extends Table {
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
  TextColumn get title => text().withLength(min: 1, max: 150)();
  RealColumn get value => real()();
  RealColumn get weight => real().withDefault(const Constant(1.0))();
  TextColumn get kind => text().withDefault(const Constant('exam'))(); // exam, assignment, concept, participation
  DateTimeColumn get date => dateTime()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
