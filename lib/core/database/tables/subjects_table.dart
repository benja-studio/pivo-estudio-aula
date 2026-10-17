import 'package:drift/drift.dart';

@DataClassName('SubjectRow')
class SubjectsTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  TextColumn get code => text().nullable()();
  IntColumn get colorValue => integer()();
  TextColumn get iconName => text().withDefault(const Constant('book'))();
  TextColumn get professor => text().nullable()();
  TextColumn get classroom => text().nullable()();
  IntColumn get credits => integer().nullable()();
  TextColumn get status => text().withDefault(const Constant('taking'))();
  TextColumn get period => text().nullable()();
  RealColumn get customPassingGrade => real().nullable()();
  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
