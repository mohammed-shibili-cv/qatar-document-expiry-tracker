import 'package:flutter/material.dart';
import 'package:qatar_document_expiry_tracker/app_scope.dart';
import 'package:qatar_document_expiry_tracker/models/document_type_template.dart';
import 'package:qatar_document_expiry_tracker/models/tracked_document.dart';
import 'package:qatar_document_expiry_tracker/screens/home/home_screen.dart';

/// Step 1: pick which Qatar document types apply.
class OnboardingTypeScreen extends StatefulWidget {
  const OnboardingTypeScreen({super.key});

  @override
  State<OnboardingTypeScreen> createState() => _OnboardingTypeScreenState();
}

class _OnboardingTypeScreenState extends State<OnboardingTypeScreen> {
  final Set<String> _selected = {'qid'};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Qatar Docs',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Which documents do you need to track?',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Everything stays on this device. You can add more later.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: [
                  for (final template in DocumentTypeTemplate.qatarDefaults)
                    CheckboxListTile(
                      value: _selected.contains(template.id),
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            _selected.add(template.id);
                          } else {
                            _selected.remove(template.id);
                          }
                        });
                      },
                      title: Text(template.label),
                      subtitle: Text(
                        '${template.description} · renew ~${template.defaultRenewalWindowDays}d before',
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: FilledButton(
                onPressed: _selected.isEmpty
                    ? null
                    : () {
                        final templates = DocumentTypeTemplate.qatarDefaults
                            .where((t) => _selected.contains(t.id))
                            .toList();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => OnboardingDatesScreen(
                              templates: templates,
                            ),
                          ),
                        );
                      },
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Step 2: enter expiry dates for selected types, then land on home.
class OnboardingDatesScreen extends StatefulWidget {
  const OnboardingDatesScreen({super.key, required this.templates});

  final List<DocumentTypeTemplate> templates;

  @override
  State<OnboardingDatesScreen> createState() => _OnboardingDatesScreenState();
}

class _OnboardingDatesScreenState extends State<OnboardingDatesScreen> {
  late final Map<String, DateTime?> _expiryByType;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _expiryByType = {
      for (final t in widget.templates) t.id: null,
    };
  }

  Future<void> _pickDate(DocumentTypeTemplate template) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 180)),
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 20),
      helpText: 'Expiry date — ${template.label}',
    );
    if (picked != null) {
      setState(() => _expiryByType[template.id] = picked);
    }
  }

  Future<void> _finish() async {
    final missing = widget.templates
        .where((t) => _expiryByType[t.id] == null)
        .map((t) => t.label)
        .toList();
    if (missing.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Add expiry dates for: ${missing.join(', ')}')),
      );
      return;
    }

    setState(() => _saving = true);
    final scope = AppScope.of(context);

    try {
      for (final template in widget.templates) {
        final expiry = _expiryByType[template.id]!;
        final draft = TrackedDocument(
          id: 'pending',
          typeId: template.id,
          typeLabel: template.label,
          expiryDate: expiry,
          renewalWindowDays: template.defaultRenewalWindowDays,
        );
        await scope.saveDocument(draft, isNew: true);
      }
      await scope.settings.setOnboardingComplete(true);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expiry dates')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Enter the expiry date for each document. Issue dates and numbers can be added later.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          for (final template in widget.templates)
            Card(
              child: ListTile(
                title: Text(template.label),
                subtitle: Text(
                  _expiryByType[template.id] == null
                      ? 'Tap to set expiry'
                      : 'Expires ${_expiryByType[template.id]!.toLocal().toString().split(' ').first}',
                ),
                trailing: const Icon(Icons.event),
                onTap: () => _pickDate(template),
              ),
            ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _finish,
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Go to home'),
          ),
        ],
      ),
    );
  }
}
