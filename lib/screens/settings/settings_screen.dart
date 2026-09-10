import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qatar_document_expiry_tracker/app_scope.dart';
import 'package:qatar_document_expiry_tracker/models/reminder_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _choices = [60, 30, 14, 7, 3, 1];

  bool _loaded = false;
  late ReminderSettings _settings;
  late Set<int> _selectedIntervals;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _settings = AppScope.of(context).settings.getReminderSettings();
      _selectedIntervals = Set<int>.from(_settings.intervalsDays);
      _loaded = true;
    }
  }

  Future<void> _persist() async {
    final next = _settings.copyWith(
      intervalsDays: (_selectedIntervals.toList()..sort((a, b) => b.compareTo(a))),
    );
    await AppScope.of(context).applyReminderSettings(next);
    setState(() => _settings = next);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reminder settings saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final encryption = AppScope.of(context).settings.encryptionEnabled;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Local reminders'),
            subtitle: Text(
              kIsWeb
                  ? 'Scheduled local notifications are limited on web — use Android/iOS for full offline reminders.'
                  : 'Notify before expiry using on-device scheduling (no FCM).',
            ),
            value: _settings.enabled,
            onChanged: (v) {
              setState(() => _settings = _settings.copyWith(enabled: v));
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              'Remind me before expiry',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          for (final days in _choices)
            CheckboxListTile(
              value: _selectedIntervals.contains(days),
              onChanged: !_settings.enabled
                  ? null
                  : (checked) {
                      setState(() {
                        if (checked == true) {
                          _selectedIntervals.add(days);
                        } else if (_selectedIntervals.length > 1) {
                          _selectedIntervals.remove(days);
                        }
                      });
                    },
              title: Text(days == 1 ? '1 day before' : '$days days before'),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: _selectedIntervals.isEmpty ? null : _persist,
              child: const Text('Save reminder settings'),
            ),
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              encryption ? Icons.lock_outline : Icons.lock_open_outlined,
            ),
            title: const Text('Document storage'),
            subtitle: Text(
              encryption
                  ? 'Documents box is AES-encrypted; key kept in platform secure storage.'
                  : 'Encryption unavailable on this platform — treat device storage carefully. See PRODUCT.md.',
            ),
          ),
          const ListTile(
            leading: Icon(Icons.workspace_premium_outlined),
            title: Text('Premium / household'),
            subtitle: Text('Coming soon — not part of v1.'),
          ),
        ],
      ),
    );
  }
}
