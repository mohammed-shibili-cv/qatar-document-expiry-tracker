import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qatar_document_expiry_tracker/app_scope.dart';
import 'package:qatar_document_expiry_tracker/models/tracked_document.dart';
import 'package:qatar_document_expiry_tracker/screens/document/document_form_screen.dart';
import 'package:qatar_document_expiry_tracker/screens/settings/settings_screen.dart';
import 'package:qatar_document_expiry_tracker/widgets/document_list_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Qatar Docs'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<Box<Map>>(
        valueListenable: scope.documents.listenable(),
        builder: (context, _, __) {
          final docs = scope.documents.getAll();
          if (docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.folder_open_outlined,
                      size: 56,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No documents yet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add a QID, health card, or other document to start tracking expiry offline.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(
                  'Sorted by days remaining · green >30 · amber 7–30 · red <7',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 88, top: 4),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    return DocumentListTile(
                      document: doc,
                      onTap: () => _openForm(context, doc),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context, null),
        icon: const Icon(Icons.add),
        label: const Text('Add document'),
      ),
    );
  }

  void _openForm(BuildContext context, TrackedDocument? existing) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DocumentFormScreen(existing: existing),
      ),
    );
  }
}
