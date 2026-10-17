// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topics_dao.dart';

// ignore_for_file: type=lint
mixin _$TopicsDaoMixin on DatabaseAccessor<AppDatabase> {
  $SubjectsTableTable get subjectsTable => attachedDatabase.subjectsTable;
  $ExamsTableTable get examsTable => attachedDatabase.examsTable;
  $TopicsTableTable get topicsTable => attachedDatabase.topicsTable;
  TopicsDaoManager get managers => TopicsDaoManager(this);
}

class TopicsDaoManager {
  final _$TopicsDaoMixin _db;
  TopicsDaoManager(this._db);
  $$SubjectsTableTableTableManager get subjectsTable =>
      $$SubjectsTableTableTableManager(_db.attachedDatabase, _db.subjectsTable);
  $$ExamsTableTableTableManager get examsTable =>
      $$ExamsTableTableTableManager(_db.attachedDatabase, _db.examsTable);
  $$TopicsTableTableTableManager get topicsTable =>
      $$TopicsTableTableTableManager(_db.attachedDatabase, _db.topicsTable);
}
