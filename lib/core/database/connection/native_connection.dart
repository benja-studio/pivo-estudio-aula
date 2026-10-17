import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Opens native SQLite database connection inside app's private documents directory
/// with WAL (Write-Ahead Logging) mode and foreign keys enabled.
LazyDatabase openNativeConnection({String dbName = 'aula_database.sqlite'}) {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, dbName));

    return NativeDatabase.createInBackground(
      file,
      setup: (database) {
        // Enforce WAL mode for fast concurrent read/write and integrity
        database.execute('PRAGMA journal_mode = WAL;');
        // Enforce foreign key constraints
        database.execute('PRAGMA foreign_keys = ON;');
      },
    );
  });
}
