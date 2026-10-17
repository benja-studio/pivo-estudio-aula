// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grades_dao.dart';

// ignore_for_file: type=lint
mixin _$GradesDaoMixin on DatabaseAccessor<AppDatabase> {
  $SubjectsTableTable get subjectsTable => attachedDatabase.subjectsTable;
  $ExamsTableTable get examsTable => attachedDatabase.examsTable;
  $GradesTableTable get gradesTable => attachedDatabase.gradesTable;
  GradesDaoManager get managers => GradesDaoManager(this);
}

class GradesDaoManager {
  final _$GradesDaoMixin _db;
  GradesDaoManager(this._db);
  $$SubjectsTableTableTableManager get subjectsTable =>
      $$SubjectsTableTableTableManager(_db.attachedDatabase, _db.subjectsTable);
  $$ExamsTableTableTableManager get examsTable =>
      $$ExamsTableTableTableManager(_db.attachedDatabase, _db.examsTable);
  $$GradesTableTableTableManager get gradesTable =>
      $$GradesTableTableTableManager(_db.attachedDatabase, _db.gradesTable);
}
