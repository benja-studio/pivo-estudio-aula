import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FileService {
  const FileService();

  /// Compresses and saves an avatar image to the private app storage directory.
  /// Returns the relative path to store in the database.
  Future<String> saveAvatar(File sourceFile) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final avatarsDir = Directory(p.join(docsDir.path, 'avatars'));
    if (!await avatarsDir.exists()) {
      await avatarsDir.create(recursive: true);
    }

    final bytes = await sourceFile.readAsBytes();
    final decoded = img.decodeImage(bytes);

    if (decoded == null) {
      throw Exception('No se pudo procesar la imagen seleccionada');
    }

    // Square crop to center
    final minDim = decoded.width < decoded.height ? decoded.width : decoded.height;
    final x = (decoded.width - minDim) ~/ 2;
    final y = (decoded.height - minDim) ~/ 2;
    final cropped = img.copyCrop(decoded, x: x, y: y, width: minDim, height: minDim);

    // Resize to high-density 400x400 avatar
    final resized = img.copyResize(cropped, width: 400, height: 400, interpolation: img.Interpolation.linear);

    // Encode to optimized JPEG (85% quality)
    final jpgBytes = img.encodeJpg(resized, quality: 85);

    final filename = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final targetFile = File(p.join(avatarsDir.path, filename));
    await targetFile.writeAsBytes(jpgBytes);

    // Return relative path for portability across backups
    return p.join('avatars', filename);
  }

  /// Resolves a relative path to absolute File
  Future<File?> getAbsoluteFile(String? relativePath) async {
    if (relativePath == null || relativePath.isEmpty) return null;
    final docsDir = await getApplicationDocumentsDirectory();
    final file = File(p.join(docsDir.path, relativePath));
    return await file.exists() ? file : null;
  }
}

final fileServiceProvider = Provider<FileService>((ref) {
  return const FileService();
});
