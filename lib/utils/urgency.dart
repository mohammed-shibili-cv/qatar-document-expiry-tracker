import 'package:flutter/material.dart';

/// Color-coding for days remaining until expiry.
///
/// - Green: more than 30 days
/// - Amber: 7–30 days inclusive
/// - Red: fewer than 7 days, or already expired
enum UrgencyLevel { green, amber, red }

UrgencyLevel urgencyForDaysRemaining(int daysRemaining) {
  if (daysRemaining < 7) return UrgencyLevel.red;
  if (daysRemaining <= 30) return UrgencyLevel.amber;
  return UrgencyLevel.green;
}

Color urgencyColor(UrgencyLevel level) {
  switch (level) {
    case UrgencyLevel.green:
      return const Color(0xFF2E7D32);
    case UrgencyLevel.amber:
      return const Color(0xFFF9A825);
    case UrgencyLevel.red:
      return const Color(0xFFC62828);
  }
}

Color urgencyContainerColor(UrgencyLevel level) {
  switch (level) {
    case UrgencyLevel.green:
      return const Color(0xFFE8F5E9);
    case UrgencyLevel.amber:
      return const Color(0xFFFFF8E1);
    case UrgencyLevel.red:
      return const Color(0xFFFFEBEE);
  }
}

String urgencyLabel(int daysRemaining) {
  if (daysRemaining < 0) {
    final overdue = -daysRemaining;
    return overdue == 1 ? 'Expired yesterday' : 'Expired $overdue days ago';
  }
  if (daysRemaining == 0) return 'Expires today';
  if (daysRemaining == 1) return '1 day left';
  return '$daysRemaining days left';
}
