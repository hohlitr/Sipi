import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
      appBar: AppBar(
        title: Text(collection?.title ?? 'Collection'),
        actions: [
          IconButton(
            onPressed: () => context.go('/quiz/$collectionId'),
            icon: const Icon(Icons.quiz),
          ),
          IconButton(
            onPressed: () => _showEditCollectionSheet(context, ref, collection?.title ?? '', collection?.description ?? ''),
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () async {
              await ref.read(collectionsRepositoryProvider).deleteCollection(collectionId);
              ref.invalidate(collectionsProvider);
              ref.invalidate(userStatsProvider);
              if (context.mounted) context.go('/collections');
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
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
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${(card.masteryLevel * 100).round()}%'),
                    IconButton(
                      onPressed: () => _showEditCardSheet(context, ref, card.id, card.question, card.answer, card.note ?? ''),
                      icon: const Icon(Icons.edit, size: 20),
                    ),
                    IconButton(
                      onPressed: () async {
                        await ref.read(collectionsRepositoryProvider).deleteCard(card.id);
                        ref.invalidate(cardsForCollectionProvider(collectionId));
                        ref.invalidate(weakCardsProvider(collectionId));
                        ref.invalidate(userStatsProvider);
                      },
                      icon: const Icon(Icons.delete_outline, size: 20),
                    ),
                  ],
                ),
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
                onPressed: () async {
                  await ref.read(collectionsRepositoryProvider).addCard(
                        collectionId: collectionId,
                        question: questionController.text.trim(),
                        answer: answerController.text.trim(),
                        note: noteController.text.trim(),
                      );
                  ref.invalidate(cardsForCollectionProvider(collectionId));
                  ref.invalidate(weakCardsProvider(collectionId));
                  ref.invalidate(userStatsProvider);
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: const Text('Add card'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showEditCollectionSheet(
    BuildContext context,
    WidgetRef ref,
    String currentTitle,
    String currentDescription,
  ) async {
    final titleController = TextEditingController(text: currentTitle);
    final descriptionController = TextEditingController(text: currentDescription);

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
                  await ref.read(collectionsRepositoryProvider).updateCollection(
                        collectionId: collectionId,
                        title: titleController.text.trim(),
                        description: descriptionController.text.trim(),
                      );
                  ref.invalidate(collectionProvider(collectionId));
                  ref.invalidate(collectionsProvider);
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: const Text('Save changes'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showEditCardSheet(
    BuildContext context,
    WidgetRef ref,
    String cardId,
    String currentQuestion,
    String currentAnswer,
    String currentNote,
  ) async {
    final questionController = TextEditingController(text: currentQuestion);
    final answerController = TextEditingController(text: currentAnswer);
    final noteController = TextEditingController(text: currentNote);

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
                onPressed: () async {
                  await ref.read(collectionsRepositoryProvider).updateCard(
                        cardId: cardId,
                        question: questionController.text.trim(),
                        answer: answerController.text.trim(),
                        note: noteController.text.trim(),
                      );
                  ref.invalidate(cardsForCollectionProvider(collectionId));
                  ref.invalidate(weakCardsProvider(collectionId));
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: const Text('Save card'),
              ),
            ],
          ),
        );
      },
    );
  }
}
