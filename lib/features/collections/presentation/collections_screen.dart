import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/collections_providers.dart';

class CollectionsScreen extends ConsumerWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collections = ref.watch(collectionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Collections'),
        actions: [
          IconButton(
            onPressed: () => context.go('/progress'),
            icon: const Icon(Icons.bar_chart),
          ),
          IconButton(
            onPressed: () => context.go('/profile'),
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateCollectionSheet(context, ref),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: collections.length,
        itemBuilder: (context, index) {
          final collection = collections[index];
          final cards = ref.watch(cardsForCollectionProvider(collection.id));

          return ListTile(
            title: Text(collection.title),
            subtitle: Text('${cards.length} cards'),
            onTap: () => context.go('/collections/${collection.id}'),
          );
        },
      ),
    );
  }

  Future<void> _showCreateCollectionSheet(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Collection title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  await ref.read(collectionsRepositoryProvider).addCollection(
                        titleController.text.trim(),
                        descriptionController.text.trim(),
                      );
                  ref.invalidate(collectionsProvider);
                  ref.invalidate(userStatsProvider);
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: const Text('Create collection'),
              ),
            ],
          ),
        );
      },
    );
  }
}
