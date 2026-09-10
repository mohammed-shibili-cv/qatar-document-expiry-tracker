import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qatar_document_expiry_tracker/data/local_store.dart';
import 'package:qatar_document_expiry_tracker/models/tracked_document.dart';
import 'package:uuid/uuid.dart';

/// CRUD for [TrackedDocument] persisted in the encrypted Hive box.
class DocumentRepository {
  DocumentRepository({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;

  List<TrackedDocument> getAll() {
    final docs = LocalStore.documentsBox.values
        .map((raw) => TrackedDocument.fromMap(Map<dynamic, dynamic>.from(raw)))
        .toList();
    docs.sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));
    return docs;
  }

  TrackedDocument? getById(String id) {
    final raw = LocalStore.documentsBox.get(id);
    if (raw == null) return null;
    return TrackedDocument.fromMap(Map<dynamic, dynamic>.from(raw));
  }

  Future<TrackedDocument> create({
    required String typeId,
    required String typeLabel,
    String? documentNumber,
    DateTime? issueDate,
    required DateTime expiryDate,
    required int renewalWindowDays,
    String? notes,
    String? photoPath,
  }) async {
    final doc = TrackedDocument(
      id: _uuid.v4(),
      typeId: typeId,
      typeLabel: typeLabel,
      documentNumber: _normalizeSensitive(documentNumber),
      issueDate: issueDate,
      expiryDate: expiryDate,
      renewalWindowDays: renewalWindowDays,
      notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
      photoPath: photoPath,
    );
    await LocalStore.documentsBox.put(doc.id, doc.toMap());
    return doc;
  }

  Future<TrackedDocument> update(TrackedDocument document) async {
    final sanitized = document.copyWith(
      documentNumber: _normalizeSensitive(document.documentNumber),
    );
    await LocalStore.documentsBox.put(sanitized.id, sanitized.toMap());
    return sanitized;
  }

  Future<void> delete(String id) async {
    await LocalStore.documentsBox.delete(id);
  }

  ValueListenable<Box<Map>> listenable() =>
      LocalStore.documentsBox.listenable();

  static String? _normalizeSensitive(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
