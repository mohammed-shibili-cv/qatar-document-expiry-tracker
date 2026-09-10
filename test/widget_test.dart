import 'package:flutter_test/flutter_test.dart';
import 'package:qatar_document_expiry_tracker/models/tracked_document.dart';
import 'package:qatar_document_expiry_tracker/utils/urgency.dart';

void main() {
  group('urgencyForDaysRemaining', () {
    test('green when more than 30 days', () {
      expect(urgencyForDaysRemaining(31), UrgencyLevel.green);
      expect(urgencyForDaysRemaining(100), UrgencyLevel.green);
    });

    test('amber when 7 to 30 days inclusive', () {
      expect(urgencyForDaysRemaining(30), UrgencyLevel.amber);
      expect(urgencyForDaysRemaining(7), UrgencyLevel.amber);
    });

    test('red when under 7 days or expired', () {
      expect(urgencyForDaysRemaining(6), UrgencyLevel.red);
      expect(urgencyForDaysRemaining(0), UrgencyLevel.red);
      expect(urgencyForDaysRemaining(-3), UrgencyLevel.red);
    });
  });

  group('TrackedDocument', () {
    test('toString never includes document number', () {
      final doc = TrackedDocument(
        id: 'abc',
        typeId: 'qid',
        typeLabel: 'QID',
        documentNumber: 'SENSITIVE-SHOULD-NOT-APPEAR',
        expiryDate: DateTime(2030, 1, 1),
        renewalWindowDays: 90,
      );
      expect(doc.toString(), isNot(contains('SENSITIVE')));
      expect(doc.toString(), contains('QID'));
    });

    test('list sort key uses days remaining', () {
      final soon = TrackedDocument(
        id: '1',
        typeId: 'qid',
        typeLabel: 'QID',
        expiryDate: DateTime.now().add(const Duration(days: 5)),
        renewalWindowDays: 90,
      );
      final later = TrackedDocument(
        id: '2',
        typeId: 'passport',
        typeLabel: 'Passport',
        expiryDate: DateTime.now().add(const Duration(days: 200)),
        renewalWindowDays: 180,
      );
      final list = [later, soon]..sort(
          (a, b) => a.daysRemaining.compareTo(b.daysRemaining),
        );
      expect(list.first.id, '1');
    });
  });
}
