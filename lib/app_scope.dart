import 'package:flutter/material.dart';
import 'package:qatar_document_expiry_tracker/data/document_repository.dart';
import 'package:qatar_document_expiry_tracker/data/settings_repository.dart';
import 'package:qatar_document_expiry_tracker/models/reminder_settings.dart';
import 'package:qatar_document_expiry_tracker/models/tracked_document.dart';
import 'package:qatar_document_expiry_tracker/services/notification_service.dart';
import 'package:qatar_document_expiry_tracker/services/photo_service.dart';

/// Shared services + repositories for the widget tree.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.documents,
    required this.settings,
    required this.notifications,
    required this.photos,
    required super.child,
  });

  final DocumentRepository documents;
  final SettingsRepository settings;
  final NotificationService notifications;
  final PhotoService photos;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found');
    return scope!;
  }

  Future<TrackedDocument> saveDocument(TrackedDocument draft, {bool isNew = false}) async {
    final saved = isNew
        ? await documents.create(
            typeId: draft.typeId,
            typeLabel: draft.typeLabel,
            documentNumber: draft.documentNumber,
            issueDate: draft.issueDate,
            expiryDate: draft.expiryDate,
            renewalWindowDays: draft.renewalWindowDays,
            notes: draft.notes,
            photoPath: draft.photoPath,
          )
        : await documents.update(draft);

    final reminder = settings.getReminderSettings();
    await notifications.rescheduleForDocument(saved, reminder);
    return saved;
  }

  Future<void> deleteDocument(TrackedDocument doc) async {
    await notifications.cancelForDocument(doc.id);
    await photos.deleteIfExists(doc.photoPath);
    await documents.delete(doc.id);
  }

  Future<void> applyReminderSettings(ReminderSettings reminder) async {
    await settings.saveReminderSettings(reminder);
    await notifications.rescheduleAll(documents.getAll(), reminder);
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => false;
}
