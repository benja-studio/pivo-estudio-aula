import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:aula/core/database/app_database.dart';
import 'package:aula/core/errors/failure.dart';
import 'package:aula/core/errors/result.dart';

class BackupService {
  BackupService({required this.database}) : _sha256 = Sha256(), _aesGcm = AesGcm.with256bits();

  final AppDatabase database;
  final Sha256 _sha256;
  final AesGcm _aesGcm;

  static const _magicEncHeader = 'AULA_ENC_V1:';
  static const int _maxRotatingBackups = 5;

  /// Checkpoints SQLite WAL mode to guarantee zero uncommitted data in WAL file
  Future<void> _checkpointDb() async {
    try {
      await database.customStatement('PRAGMA wal_checkpoint(TRUNCATE);');
    } catch (_) {}
  }

  /// Calculates SHA-256 hex string for given bytes
  Future<String> _calculateSha256(List<int> bytes) async {
    final hash = await _sha256.hash(bytes);
    return hash.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Derives 256-bit AES key from user password using SHA-256
  Future<SecretKey> _deriveKeyFromPassword(String password, List<int> salt) async {
    final combined = utf8.encode(password) + salt;
    final hash = await _sha256.hash(combined);
    return await _aesGcm.newSecretKeyFromBytes(hash.bytes);
  }

  /// Exports full backup as ZIP with SHA-256 integrity manifest.
  /// Optionally encrypts the payload using AES-GCM 256-bit with the provided password.
  Future<Result<String>> exportBackup({String? password}) async {
    try {
      await _checkpointDb();

      final docsDir = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(docsDir.path, 'aula_database.sqlite'));

      if (!await dbFile.exists()) {
        return Result.failure(const StorageFailure('Base de datos no encontrada'));
      }

      final dbBytes = await dbFile.readAsBytes();
      final dbChecksum = await _calculateSha256(dbBytes);

      final archive = Archive();
      archive.addFile(ArchiveFile('aula_database.sqlite', dbBytes.length, dbBytes));

      // Add avatars
      final avatarsDir = Directory(p.join(docsDir.path, 'avatars'));
      int avatarCount = 0;
      if (await avatarsDir.exists()) {
        final avatarFiles = avatarsDir.listSync().whereType<File>();
        for (final file in avatarFiles) {
          final fileBytes = await file.readAsBytes();
          final relativeName = p.join('avatars', p.basename(file.path));
          archive.addFile(ArchiveFile(relativeName, fileBytes.length, fileBytes));
          avatarCount++;
        }
      }

      // Add manifest
      final manifestMap = {
        'app': 'Aula',
        'version': '1.0.0',
        'schemaVersion': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'dbChecksum': dbChecksum,
        'avatarCount': avatarCount,
        'isEncrypted': password != null && password.isNotEmpty,
      };

      final manifestBytes = utf8.encode(jsonEncode(manifestMap));
      archive.addFile(ArchiveFile('manifest.json', manifestBytes.length, manifestBytes));

      final zipData = ZipEncoder().encode(archive);
      Uint8List finalBytes;

      if (password != null && password.isNotEmpty) {
        // Encrypt ZIP data with AES-GCM
        final salt = Uint8List(16);
        for (int i = 0; i < 16; i++) {
          salt[i] = (i * 37 + DateTime.now().millisecond) % 256;
        }
        final secretKey = await _deriveKeyFromPassword(password, salt);
        final secretBox = await _aesGcm.encrypt(zipData, secretKey: secretKey);

        final headerBytes = utf8.encode(_magicEncHeader);
        final builder = BytesBuilder();
        builder.add(headerBytes);
        builder.add(salt);
        builder.add(secretBox.nonce);
        builder.add(secretBox.mac.bytes);
        builder.add(secretBox.cipherText);
        finalBytes = builder.toBytes();
      } else {
        finalBytes = Uint8List.fromList(zipData);
      }

      // Save to temporary export file
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
      final ext = password != null && password.isNotEmpty ? 'aula' : 'zip';
      final exportPath = p.join(tempDir.path, 'aula_backup_$timestamp.$ext');
      final exportFile = File(exportPath);
      await exportFile.writeAsBytes(finalBytes, flush: true);

      // Trigger native share sheet
      await Share.shareXFiles(
        [XFile(exportPath)],
        subject: 'Copia de seguridad Aula ($timestamp)',
        text: 'Copia de seguridad de datos académicos de Aula.',
      );

      return Result.ok(exportPath);
    } catch (e) {
      return Result.failure(StorageFailure('Error al exportar respaldo: $e'));
    }
  }

  /// Automatically creates rotating local backup (keeps 5 latest)
  Future<void> createRotatingLocalBackup() async {
    try {
      await _checkpointDb();

      final docsDir = await getApplicationDocumentsDirectory();
      final backupsDir = Directory(p.join(docsDir.path, 'backups'));
      if (!await backupsDir.exists()) {
        await backupsDir.create(recursive: true);
      }

      final dbFile = File(p.join(docsDir.path, 'aula_database.sqlite'));
      if (!await dbFile.exists()) return;

      final dbBytes = await dbFile.readAsBytes();
      final archive = Archive();
      archive.addFile(ArchiveFile('aula_database.sqlite', dbBytes.length, dbBytes));

      final zipData = ZipEncoder().encode(archive);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupFile = File(p.join(backupsDir.path, 'auto_backup_$timestamp.zip'));
      await backupFile.writeAsBytes(zipData);

      // Rotate: keep only the most recent 5
      final files = backupsDir.listSync().whereType<File>().toList()
        ..sort((a, b) => b.path.compareTo(a.path));

      if (files.length > _maxRotatingBackups) {
        for (int i = _maxRotatingBackups; i < files.length; i++) {
          try {
            await files[i].delete();
          } catch (_) {}
        }
      }
    } catch (_) {}
  }

  /// Checks if a file path is password-encrypted
  Future<bool> isEncryptedBackup(String filePath) async {
    try {
      final file = File(filePath);
      final headerBytes = await file.openRead(0, _magicEncHeader.length).first;
      final headerString = utf8.decode(headerBytes, allowMalformed: true);
      return headerString == _magicEncHeader;
    } catch (_) {
      return false;
    }
  }

  /// Imports and restores a backup from selected file with checksum verification
  Future<Result<bool>> importBackupFromFile({required String filePath, String? password}) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return Result.failure(const StorageFailure('El archivo seleccionado no existe'));
      }

      final fileBytes = await file.readAsBytes();
      Uint8List zipBytes;

      // Check if encrypted
      final magicLength = utf8.encode(_magicEncHeader).length;
      if (fileBytes.length > magicLength &&
          utf8.decode(fileBytes.sublist(0, magicLength), allowMalformed: true) == _magicEncHeader) {
        if (password == null || password.isEmpty) {
          return Result.failure(const StorageFailure('El respaldo está protegido por contraseña. Ingresa la contraseña para restaurarlo.'));
        }

        int offset = magicLength;
        final salt = fileBytes.sublist(offset, offset + 16);
        offset += 16;
        final nonce = fileBytes.sublist(offset, offset + 12);
        offset += 12;
        final macBytes = fileBytes.sublist(offset, offset + 16);
        offset += 16;
        final cipherText = fileBytes.sublist(offset);

        final secretKey = await _deriveKeyFromPassword(password, salt);
        final secretBox = SecretBox(cipherText, nonce: nonce, mac: Mac(macBytes));

        try {
          final decrypted = await _aesGcm.decrypt(secretBox, secretKey: secretKey);
          zipBytes = Uint8List.fromList(decrypted);
        } catch (_) {
          return Result.failure(const StorageFailure('Contraseña incorrecta o archivo dañado'));
        }
      } else {
        zipBytes = fileBytes;
      }

      // Unpack ZIP
      Archive archive;
      try {
        archive = ZipDecoder().decodeBytes(zipBytes);
      } catch (e) {
        return Result.failure(const StorageFailure('El archivo no es un archivo de respaldo válido'));
      }

      // Read manifest
      final manifestFile = archive.findFile('manifest.json');
      if (manifestFile == null) {
        return Result.failure(const StorageFailure('El respaldo no contiene un archivo manifest.json válido'));
      }

      final manifestJson = jsonDecode(utf8.decode(manifestFile.content as List<int>)) as Map<String, dynamic>;
      final expectedDbChecksum = manifestJson['dbChecksum'] as String?;

      final dbArchiveFile = archive.findFile('aula_database.sqlite');
      if (dbArchiveFile == null) {
        return Result.failure(const StorageFailure('El respaldo no contiene la base de datos'));
      }

      final restoredDbBytes = dbArchiveFile.content as List<int>;
      if (expectedDbChecksum != null) {
        final actualChecksum = await _calculateSha256(restoredDbBytes);
        if (actualChecksum != expectedDbChecksum) {
          return Result.failure(const StorageFailure('Fallo de integridad: La suma de verificación SHA-256 no coincide'));
        }
      }

      // Write DB file to app directory
      final docsDir = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(docsDir.path, 'aula_database.sqlite'));
      await dbFile.writeAsBytes(restoredDbBytes, flush: true);

      // Restore avatars
      final avatarsDir = Directory(p.join(docsDir.path, 'avatars'));
      if (!await avatarsDir.exists()) {
        await avatarsDir.create(recursive: true);
      }

      for (final archiveItem in archive) {
        if (archiveItem.name.startsWith('avatars/') && archiveItem.isFile) {
          final targetAvatar = File(p.join(docsDir.path, archiveItem.name));
          await targetAvatar.writeAsBytes(archiveItem.content as List<int>, flush: true);
        }
      }

      return Result.ok(true);
    } catch (e) {
      return Result.failure(StorageFailure('Error al restaurar respaldo: $e'));
    }
  }

  /// Completely wipes all user data and resets database cleanly
  Future<Result<bool>> wipeAllData() async {
    try {
      // Delete rows across all tables in order respecting foreign keys
      await database.customStatement('DELETE FROM reminders_table;');
      await database.customStatement('DELETE FROM grades_table;');
      await database.customStatement('DELETE FROM topics_table;');
      await database.customStatement('DELETE FROM exams_table;');
      await database.customStatement('DELETE FROM schedule_slots_table;');
      await database.customStatement('DELETE FROM subjects_table;');
      await database.customStatement('DELETE FROM student_profiles_table;');
      await _checkpointDb();

      // Delete avatars
      final docsDir = await getApplicationDocumentsDirectory();
      final avatarsDir = Directory(p.join(docsDir.path, 'avatars'));
      if (await avatarsDir.exists()) {
        await avatarsDir.delete(recursive: true);
      }

      return Result.ok(true);
    } catch (e) {
      return Result.failure(StorageFailure('Error al eliminar datos: $e'));
    }
  }
}

final backupServiceProvider = Provider<BackupService>((ref) {
  final db = ref.watch(databaseProvider);
  return BackupService(database: db);
});
