import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Manages Hive bootstrap and AES encryption key for the documents box.
///
/// Document numbers and other fields live in the encrypted `documents` box.
/// Never log document numbers.
class LocalStore {
  LocalStore._();

  static const documentsBoxName = 'documents';
  static const settingsBoxName = 'settings';
  static const _hiveKeyStorageKey = 'hive_documents_aes_key';

  static late Box<Map> documentsBox;
  static late Box settingsBox;
  static bool encryptionEnabled = false;

  static Future<void> init() async {
    await Hive.initFlutter();

    final cipher = await _openCipher();
    if (cipher != null) {
      documentsBox = await Hive.openBox<Map>(
        documentsBoxName,
        encryptionCipher: cipher,
      );
      encryptionEnabled = true;
    } else {
      // Fallback: open unencrypted and surface in PRODUCT / Settings.
      documentsBox = await Hive.openBox<Map>(documentsBoxName);
      encryptionEnabled = false;
      debugPrint(
        'LocalStore: documents box opened without AES encryption '
        '(secure key storage unavailable on this platform).',
      );
    }

    settingsBox = await Hive.openBox(settingsBoxName);
  }

  static Future<HiveAesCipher?> _openCipher() async {
    try {
      const storage = FlutterSecureStorage();
      var encoded = await storage.read(key: _hiveKeyStorageKey);
      if (encoded == null) {
        final key = Hive.generateSecureKey();
        encoded = base64Encode(key);
        await storage.write(key: _hiveKeyStorageKey, value: encoded);
      }
      final bytes = base64Decode(encoded);
      return HiveAesCipher(Uint8List.fromList(bytes));
    } catch (e) {
      debugPrint('LocalStore: could not create encryption cipher: $e');
      return null;
    }
  }
}
