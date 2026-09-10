import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:qatar_document_expiry_tracker/models/reminder_settings.dart';
import 'package:qatar_document_expiry_tracker/models/tracked_document.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Offline local reminders via [flutter_local_notifications].
/// Does not use FCM or any server push.
class NotificationService {
  NotificationService();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Qatar'));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(settings: settings);

    if (!kIsWeb) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }

    _initialized = true;
  }

  /// Cancel all scheduled reminders for [document], then reschedule based on
  /// [settings]. Notification payloads never include document numbers.
  Future<void> rescheduleForDocument(
    TrackedDocument document,
    ReminderSettings settings,
  ) async {
    await cancelForDocument(document.id);

    if (!settings.enabled || kIsWeb) return;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'document_expiry',
        'Document expiry',
        channelDescription: 'Reminders before personal documents expire',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    final now = tz.TZDateTime.now(tz.local);

    for (final daysBefore in settings.intervalsDays) {
      final fireAt = _reminderMoment(document.expiryDate, daysBefore);
      if (fireAt.isBefore(now)) continue;

      final id = _notificationId(document.id, daysBefore);
      final body = daysBefore == 0
          ? '${document.typeLabel} expires today'
          : daysBefore == 1
              ? '${document.typeLabel} expires tomorrow'
              : '${document.typeLabel} expires in $daysBefore days';

      await _plugin.zonedSchedule(
        id: id,
        title: 'Document renewal reminder',
        body: body,
        scheduledDate: fireAt,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: document.id,
      );
    }
  }

  Future<void> rescheduleAll(
    List<TrackedDocument> documents,
    ReminderSettings settings,
  ) async {
    await _plugin.cancelAll();
    for (final doc in documents) {
      await rescheduleForDocument(doc, settings);
    }
  }

  Future<void> cancelForDocument(String documentId) async {
    for (final days in ReminderSettings.defaultIntervals) {
      await _plugin.cancel(id: _notificationId(documentId, days));
    }
    // Also cancel any custom intervals that might have been used.
    for (final days in [60, 90, 180, 3]) {
      await _plugin.cancel(id: _notificationId(documentId, days));
    }
  }

  tz.TZDateTime _reminderMoment(DateTime expiry, int daysBefore) {
    final day = DateTime(expiry.year, expiry.month, expiry.day)
        .subtract(Duration(days: daysBefore));
    // 9:00 AM Asia/Qatar local
    return tz.TZDateTime(tz.local, day.year, day.month, day.day, 9);
  }

  /// Stable positive 32-bit id derived from document id + interval.
  int _notificationId(String documentId, int daysBefore) {
    final hash = Object.hash(documentId, daysBefore) & 0x7fffffff;
    return hash == 0 ? 1 : hash;
  }
}
