// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exams_dao.dart';

// ignore_for_file: type=lint
mixin _$ExamsDaoMixin on DatabaseAccessor<AppDatabase> {
  $SubjectsTableTable get subjectsTable => attachedDatabase.subjectsTable;
  $ExamsTableTable get examsTable => attachedDatabase.examsTable;
  ExamsDaoManager get managers => ExamsDaoManager(this);
}

class ExamsDaoManager {
  final _$ExamsDaoMixin _db;
  ExamsDaoManager(this._db);
  $$SubjectsTableTableTableManager get subjectsTable =>
      $$SubjectsTableTableTableManager(_db.attachedDatabase, _db.subjectsTable);
  $$ExamsTableTableTableManager get examsTable =>
      $$ExamsTableTableTableManager(_db.attachedDatabase, _db.examsTable);
}
