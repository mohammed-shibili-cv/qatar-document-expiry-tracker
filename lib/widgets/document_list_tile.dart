import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qatar_document_expiry_tracker/models/tracked_document.dart';
import 'package:qatar_document_expiry_tracker/utils/urgency.dart';
import 'package:qatar_document_expiry_tracker/widgets/urgency_chip.dart';

class DocumentListTile extends StatelessWidget {
  const DocumentListTile({
    super.key,
    required this.document,
    required this.onTap,
  });

  final TrackedDocument document;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final level = urgencyForDaysRemaining(document.daysRemaining);
    final dateFmt = DateFormat.yMMMd();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 56,
                decoration: BoxDecoration(
                  color: urgencyColor(level),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.typeLabel,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Expires ${dateFmt.format(document.expiryDate)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              UrgencyChip(daysRemaining: document.daysRemaining),
            ],
          ),
        ),
      ),
    );
  }
}
