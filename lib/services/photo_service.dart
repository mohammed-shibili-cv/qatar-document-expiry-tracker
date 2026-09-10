import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Copies gallery / camera images into app documents storage.
class PhotoService {
  PhotoService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<String?> pickAndPersist({required ImageSource source}) async {
    if (kIsWeb) {
      // Web: store the blob path from the picker for display; persistence is
      // ephemeral compared to mobile app documents. Documented in README.
      final file = await _picker.pickImage(source: source, imageQuality: 85);
      return file?.path;
    }

    final file = await _picker.pickImage(source: source, imageQuality: 85);
    if (file == null) return null;

    final dir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(dir.path, 'document_photos'));
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    final ext = p.extension(file.path).isEmpty ? '.jpg' : p.extension(file.path);
    final destPath = p.join(
      photosDir.path,
      'doc_${DateTime.now().millisecondsSinceEpoch}$ext',
    );
    await File(file.path).copy(destPath);
    return destPath;
  }

  Future<void> deleteIfExists(String? path) async {
    if (path == null || kIsWeb) return;
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
