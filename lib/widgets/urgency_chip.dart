import 'package:flutter/material.dart';
import 'package:qatar_document_expiry_tracker/utils/urgency.dart';

class UrgencyChip extends StatelessWidget {
  const UrgencyChip({super.key, required this.daysRemaining});

  final int daysRemaining;

  @override
  Widget build(BuildContext context) {
    final level = urgencyForDaysRemaining(daysRemaining);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: urgencyContainerColor(level),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: urgencyColor(level).withValues(alpha: 0.35)),
      ),
      child: Text(
        urgencyLabel(daysRemaining),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: urgencyColor(level),
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
