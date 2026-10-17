// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_dao.dart';

// ignore_for_file: type=lint
mixin _$ProfileDaoMixin on DatabaseAccessor<AppDatabase> {
  $StudentProfilesTableTable get studentProfilesTable =>
      attachedDatabase.studentProfilesTable;
  ProfileDaoManager get managers => ProfileDaoManager(this);
}

class ProfileDaoManager {
  final _$ProfileDaoMixin _db;
  ProfileDaoManager(this._db);
  $$StudentProfilesTableTableTableManager get studentProfilesTable =>
      $$StudentProfilesTableTableTableManager(
        _db.attachedDatabase,
        _db.studentProfilesTable,
      );
}
