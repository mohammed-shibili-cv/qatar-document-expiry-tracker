/// Configurable local reminder offsets (days before expiry).
class ReminderSettings {
  const ReminderSettings({
    this.intervalsDays = defaultIntervals,
    this.enabled = true,
  });

  static const List<int> defaultIntervals = [30, 14, 7, 1];

  final List<int> intervalsDays;
  final bool enabled;

  ReminderSettings copyWith({
    List<int>? intervalsDays,
    bool? enabled,
  }) {
    return ReminderSettings(
      intervalsDays: intervalsDays ?? this.intervalsDays,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toMap() => {
        'intervalsDays': intervalsDays,
        'enabled': enabled,
      };

  factory ReminderSettings.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) return const ReminderSettings();
    final raw = map['intervalsDays'];
    final intervals = raw is List
        ? raw.map((e) => e as int).toList()
        : defaultIntervals;
    return ReminderSettings(
      intervalsDays: List<int>.from(intervals)..sort((a, b) => b.compareTo(a)),
      enabled: map['enabled'] as bool? ?? true,
    );
  }
}
