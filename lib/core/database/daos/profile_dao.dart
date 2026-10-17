import 'package:drift/drift.dart';
import 'package:aula/core/database/app_database.dart';
import 'package:aula/core/database/mappers/database_mappers.dart';
import 'package:aula/core/database/tables/student_profiles_table.dart';
import 'package:aula/features/profile/domain/entities/student_profile.dart';

part 'profile_dao.g.dart';

@DriftAccessor(tables: [StudentProfilesTable])
class ProfileDao extends DatabaseAccessor<AppDatabase> with _$ProfileDaoMixin {
  ProfileDao(super.db);

  Future<StudentProfile?> getProfile() async {
    final row = await select(studentProfilesTable).getSingleOrNull();
    return row != null ? DatabaseMappers.toStudentProfile(row) : null;
  }

  Stream<StudentProfile?> watchProfile() {
    return select(studentProfilesTable)
        .watchSingleOrNull()
        .map((row) => row != null ? DatabaseMappers.toStudentProfile(row) : null);
  }

  Future<void> saveProfile(StudentProfile profile) async {
    final companion = DatabaseMappers.toStudentProfileCompanion(profile);
    await into(studentProfilesTable).insertOnConflictUpdate(companion);
  }

  Future<void> deleteAll() async {
    await delete(studentProfilesTable).go();
  }
}
