import 'package:drift/drift.dart';

@DataClassName('StudentProfileRow')
class StudentProfilesTable extends Table {
  TextColumn get id => text()();
  TextColumn get fullName => text().withLength(min: 1, max: 120)();
  TextColumn get career => text().withLength(min: 1, max: 120)();
  TextColumn get institution => text().withLength(min: 1, max: 120)();
  TextColumn get academicLevel => text().nullable()();
  TextColumn get studentId => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get currentPeriod => text().nullable()();
  TextColumn get avatarPath => text().nullable()();

  // Grade preferences
  RealColumn get passingGrade => real().withDefault(const Constant(4.0))();
  RealColumn get maxGrade => real().withDefault(const Constant(10.0))();
  TextColumn get gradeScaleType => text().withDefault(const Constant('numeric10'))();

  // Notification preference
  BoolColumn get notificationsEnabled => boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
