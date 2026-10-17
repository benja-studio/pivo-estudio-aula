// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subjects_dao.dart';

// ignore_for_file: type=lint
mixin _$SubjectsDaoMixin on DatabaseAccessor<AppDatabase> {
  $SubjectsTableTable get subjectsTable => attachedDatabase.subjectsTable;
  $ScheduleSlotsTableTable get scheduleSlotsTable =>
      attachedDatabase.scheduleSlotsTable;
  SubjectsDaoManager get managers => SubjectsDaoManager(this);
}

class SubjectsDaoManager {
  final _$SubjectsDaoMixin _db;
  SubjectsDaoManager(this._db);
  $$SubjectsTableTableTableManager get subjectsTable =>
      $$SubjectsTableTableTableManager(_db.attachedDatabase, _db.subjectsTable);
  $$ScheduleSlotsTableTableTableManager get scheduleSlotsTable =>
      $$ScheduleSlotsTableTableTableManager(
        _db.attachedDatabase,
        _db.scheduleSlotsTable,
      );
}
