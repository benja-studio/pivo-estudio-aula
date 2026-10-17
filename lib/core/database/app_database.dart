import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aula/core/database/connection/native_connection.dart';
import 'package:aula/core/database/daos/exams_dao.dart';
import 'package:aula/core/database/daos/grades_dao.dart';
import 'package:aula/core/database/daos/profile_dao.dart';
import 'package:aula/core/database/daos/subjects_dao.dart';
import 'package:aula/core/database/daos/topics_dao.dart';
import 'package:aula/core/database/tables/exams_table.dart';
import 'package:aula/core/database/tables/grades_table.dart';
import 'package:aula/core/database/tables/reminders_table.dart';
import 'package:aula/core/database/tables/schedule_slots_table.dart';
import 'package:aula/core/database/tables/student_profiles_table.dart';
import 'package:aula/core/database/tables/subjects_table.dart';
import 'package:aula/core/database/tables/topics_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    StudentProfilesTable,
    SubjectsTable,
    ScheduleSlotsTable,
    ExamsTable,
    TopicsTable,
    GradesTable,
    RemindersTable,
  ],
  daos: [
    ProfileDao,
    SubjectsDao,
    ExamsDao,
    TopicsDao,
    GradesDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? openNativeConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // Versioned migration logic will go here incrementally
        },
        beforeOpen: (details) async {
          // Crucial: enforce foreign keys on every database connection open
          await customStatement('PRAGMA foreign_keys = ON;');
        },
      );

  /// Performs a background PRAGMA integrity check on startup
  Future<bool> checkIntegrity() async {
    try {
      final rows = await customSelect('PRAGMA integrity_check;').get();
      if (rows.isNotEmpty) {
        final result = rows.first.data['integrity_check'] as String?;
        return result == 'ok';
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final profileDaoProvider = Provider<ProfileDao>((ref) {
  return ref.watch(databaseProvider).profileDao;
});

final subjectsDaoProvider = Provider<SubjectsDao>((ref) {
  return ref.watch(databaseProvider).subjectsDao;
});

final examsDaoProvider = Provider<ExamsDao>((ref) {
  return ref.watch(databaseProvider).examsDao;
});

final topicsDaoProvider = Provider<TopicsDao>((ref) {
  return ref.watch(databaseProvider).topicsDao;
});

final gradesDaoProvider = Provider<GradesDao>((ref) {
  return ref.watch(databaseProvider).gradesDao;
});
