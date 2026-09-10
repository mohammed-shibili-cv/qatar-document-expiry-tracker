import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:qatar_document_expiry_tracker/app_scope.dart';
import 'package:qatar_document_expiry_tracker/models/document_type_template.dart';
import 'package:qatar_document_expiry_tracker/models/tracked_document.dart';
import 'package:qatar_document_expiry_tracker/widgets/urgency_chip.dart';

class DocumentFormScreen extends StatefulWidget {
  const DocumentFormScreen({super.key, this.existing});

  final TrackedDocument? existing;

  @override
  State<DocumentFormScreen> createState() => _DocumentFormScreenState();
}

class _DocumentFormScreenState extends State<DocumentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _notesController = TextEditingController();
  final _customTypeController = TextEditingController();

  late String _typeId;
  late String _typeLabel;
  DateTime? _issueDate;
  late DateTime _expiryDate;
  late int _renewalWindowDays;
  String? _photoPath;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _typeId = existing.typeId;
      _typeLabel = existing.typeLabel;
      _numberController.text = existing.documentNumber ?? '';
      _notesController.text = existing.notes ?? '';
      _issueDate = existing.issueDate;
      _expiryDate = existing.expiryDate;
      _renewalWindowDays = existing.renewalWindowDays;
      _photoPath = existing.photoPath;
      if (existing.typeId == 'custom') {
        _customTypeController.text = existing.typeLabel;
      }
    } else {
      final qid = DocumentTypeTemplate.qatarDefaults.first;
      _typeId = qid.id;
      _typeLabel = qid.label;
      _expiryDate = DateTime.now().add(const Duration(days: 365));
      _renewalWindowDays = qid.defaultRenewalWindowDays;
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    _notesController.dispose();
    _customTypeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool issue}) async {
    final initial = issue ? (_issueDate ?? DateTime.now()) : _expiryDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(DateTime.now().year + 30),
    );
    if (picked == null) return;
    setState(() {
      if (issue) {
        _issueDate = picked;
      } else {
        _expiryDate = picked;
      }
    });
  }

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            if (!kIsWeb)
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    final scope = AppScope.of(context);
    final path = await scope.photos.pickAndPersist(source: source);
    if (path != null) {
      setState(() => _photoPath = path);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    var label = _typeLabel;
    var typeId = _typeId;
    if (_typeId == 'custom') {
      label = _customTypeController.text.trim();
      if (label.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a custom document name')),
        );
        return;
      }
      typeId = 'custom';
    }

    setState(() => _saving = true);
    final scope = AppScope.of(context);

    try {
      final draft = TrackedDocument(
        id: widget.existing?.id ?? 'pending',
        typeId: typeId,
        typeLabel: label,
        documentNumber: _numberController.text,
        issueDate: _issueDate,
        expiryDate: _expiryDate,
        renewalWindowDays: _renewalWindowDays,
        notes: _notesController.text,
        photoPath: _photoPath,
        createdAt: widget.existing?.createdAt,
      );
      await scope.saveDocument(draft, isNew: !_isEditing);
      if (!mounted) return;
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final existing = widget.existing;
    if (existing == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete document?'),
        content: Text(
          'Remove ${existing.typeLabel} from this device? '
          'Local reminders for it will be cancelled.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await AppScope.of(context).deleteDocument(existing);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat.yMMMd();
    final typeItems = [
      ...DocumentTypeTemplate.qatarDefaults,
      DocumentTypeTemplate.custom(label: 'Custom'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit document' : 'Add document'),
        actions: [
          if (_isEditing)
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_isEditing) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: UrgencyChip(
                  daysRemaining: widget.existing!.daysRemaining,
                ),
              ),
              const SizedBox(height: 16),
            ],
            DropdownButtonFormField<String>(
              // ignore: deprecated_member_use
              value: _typeId,
              decoration: const InputDecoration(labelText: 'Document type'),
              items: [
                for (final t in typeItems)
                  DropdownMenuItem(value: t.id, child: Text(t.label)),
              ],
              onChanged: _isEditing
                  ? null
                  : (value) {
                      if (value == null) return;
                      final template = typeItems.firstWhere((t) => t.id == value);
                      setState(() {
                        _typeId = template.id;
                        _typeLabel = template.label;
                        _renewalWindowDays = template.defaultRenewalWindowDays;
                      });
                    },
            ),
            if (_typeId == 'custom') ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _customTypeController,
                decoration: const InputDecoration(labelText: 'Custom name'),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
            ],
            const SizedBox(height: 12),
            TextFormField(
              controller: _numberController,
              decoration: const InputDecoration(
                labelText: 'Document number (optional)',
                helperText: 'Stored encrypted on-device when available. Never logged.',
              ),
              keyboardType: TextInputType.text,
              autocorrect: false,
              enableSuggestions: false,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Issue date (optional)'),
              subtitle: Text(
                _issueDate == null ? 'Not set' : dateFmt.format(_issueDate!),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_issueDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _issueDate = null),
                    ),
                  IconButton(
                    icon: const Icon(Icons.event),
                    onPressed: () => _pickDate(issue: true),
                  ),
                ],
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Expiry date'),
              subtitle: Text(dateFmt.format(_expiryDate)),
              trailing: IconButton(
                icon: const Icon(Icons.event),
                onPressed: () => _pickDate(issue: false),
              ),
            ),
            const SizedBox(height: 8),
            Text('Renewal window (days before expiry)',
                style: Theme.of(context).textTheme.titleSmall),
            Slider(
              value: _renewalWindowDays.toDouble().clamp(7, 365),
              min: 7,
              max: 365,
              divisions: 50,
              label: '$_renewalWindowDays days',
              onChanged: (v) =>
                  setState(() => _renewalWindowDays = v.round()),
            ),
            Text(
              'Suggest starting renewal about $_renewalWindowDays days before expiry.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Text('Photo attachment',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            if (_photoPath != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: kIsWeb
                    ? Image.network(_photoPath!, height: 160, fit: BoxFit.cover)
                    : Image.file(
                        File(_photoPath!),
                        height: 160,
                        fit: BoxFit.cover,
                      ),
              ),
              TextButton.icon(
                onPressed: () => setState(() => _photoPath = null),
                icon: const Icon(Icons.link_off),
                label: const Text('Remove photo'),
              ),
            ] else
              OutlinedButton.icon(
                onPressed: _pickPhoto,
                icon: const Icon(Icons.add_a_photo_outlined),
                label: const Text('Add from gallery'),
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEditing ? 'Save changes' : 'Save document'),
            ),
          ],
        ),
      ),
    );
  }
}
