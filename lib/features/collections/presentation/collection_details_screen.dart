import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/collections_providers.dart';

class CollectionDetailsScreen extends ConsumerWidget {
  final String collectionId;

  const CollectionDetailsScreen({super.key, required this.collectionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collection = ref.watch(collectionProvider(collectionId));
    final cards = ref.watch(cardsForCollectionProvider(collectionId));
    final weakCards = ref.watch(weakCardsProvider(collectionId));
    final groups = ref.watch(groupsForCollectionProvider(collectionId));

    return Scaffold(
      appBar: AppBar(title: Text(collection?.title ?? 'Collection')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCardSheet(context, ref),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (collection?.description != null) ...[
            Text(collection!.description!),
            const SizedBox(height: 16),
          ],
          Text('Cards: ${cards.length}', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...cards.map(
            (card) => Card(
              child: ListTile(
                title: Text(card.question),
                subtitle: Text(card.answer),
                trailing: Text('${(card.masteryLevel * 100).round()}%'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Weak cards', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...weakCards.map(
            (card) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(card.question),
              subtitle: Text('Mastery ${(card.masteryLevel * 100).round()}%'),
            ),
          ),
          const SizedBox(height: 16),
          Text('Groups', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...groups.map(
            (group) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(group.title),
              subtitle: Text('${group.cardIds.length} cards'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddCardSheet(BuildContext context, WidgetRef ref) async {
    final questionController = TextEditingController();
    final answerController = TextEditingController();
    final noteController = TextEditingController();

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
                controller: questionController,
                decoration: const InputDecoration(labelText: 'Question'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: answerController,
                decoration: const InputDecoration(labelText: 'Answer'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(labelText: 'Note'),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  ref.read(collectionsRepositoryProvider).addCard(
                        collectionId: collectionId,
                        question: questionController.text.trim(),
                        answer: answerController.text.trim(),
                        note: noteController.text.trim(),
                      );
                  ref.invalidate(cardsForCollectionProvider(collectionId));
                  ref.invalidate(weakCardsProvider(collectionId));
                  ref.invalidate(userStatsProvider);
                  Navigator.of(context).pop();
                },
                child: const Text('Add card'),
              ),
            ],
          ),
        );
      },
    );
  }
}
