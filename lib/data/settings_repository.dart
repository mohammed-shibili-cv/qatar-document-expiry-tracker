import 'package:qatar_document_expiry_tracker/data/local_store.dart';
import 'package:qatar_document_expiry_tracker/models/reminder_settings.dart';

class SettingsRepository {
  static const _onboardingCompleteKey = 'onboardingComplete';
  static const _reminderSettingsKey = 'reminderSettings';

  bool get isOnboardingComplete =>
      LocalStore.settingsBox.get(_onboardingCompleteKey, defaultValue: false)
          as bool;

  Future<void> setOnboardingComplete(bool value) async {
    await LocalStore.settingsBox.put(_onboardingCompleteKey, value);
  }

  ReminderSettings getReminderSettings() {
    final raw = LocalStore.settingsBox.get(_reminderSettingsKey);
    if (raw is Map) {
      return ReminderSettings.fromMap(Map<dynamic, dynamic>.from(raw));
    }
    return const ReminderSettings();
  }

  Future<void> saveReminderSettings(ReminderSettings settings) async {
    await LocalStore.settingsBox.put(_reminderSettingsKey, settings.toMap());
  }

  bool get encryptionEnabled => LocalStore.encryptionEnabled;
}
