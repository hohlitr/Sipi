import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../collections/providers/collections_providers.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(userStatsProvider);
    final collections = ref.watch(collectionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Overall accuracy'),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: stats.accuracy),
            const SizedBox(height: 12),
            Text('Collections: ${stats.totalCollections}'),
            Text('Cards: ${stats.totalCards}'),
            Text('Attempts: ${stats.totalAttempts}'),
            Text('Correct answers: ${stats.totalCorrectAnswers}'),
            const SizedBox(height: 20),
            const Text('By collection'),
            const SizedBox(height: 12),
            ...collections.map((collection) {
              final cards = ref.watch(cardsForCollectionProvider(collection.id));
              final progress = cards.isEmpty
                  ? 0.0
                  : cards.fold<double>(0, (sum, card) => sum + card.masteryLevel) / cards.length;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(collection.title),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(value: progress),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
