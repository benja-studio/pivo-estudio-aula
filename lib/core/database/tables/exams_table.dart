import 'package:drift/drift.dart';
import 'package:aula/core/database/tables/subjects_table.dart';

@DataClassName('ExamRow')
class ExamsTable extends Table {
  TextColumn get id => text()();
  TextColumn get subjectId => text().references(
        SubjectsTable,
        #id,
        onDelete: KeyAction.cascade,
      )();
  TextColumn get type => text()(); // midterm, retake, finalExam, assignment, quiz, oral
  TextColumn get title => text().withLength(min: 1, max: 150)();
  DateTimeColumn get examDate => dateTime()();
  IntColumn get durationMinutes => integer().withDefault(const Constant(120))();
  TextColumn get classroom => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))(); // pending, taken, passed, failed, absent

  // Linking retakes to original exams
  TextColumn get retakeOfExamId => text().nullable()();
  // 'replace' or 'average'
  TextColumn get retakeRule => text().withDefault(const Constant('replace'))();

  BoolColumn get reminderEnabled => boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
