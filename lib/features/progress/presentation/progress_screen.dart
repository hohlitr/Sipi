import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../collections/providers/collections_providers.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(userStatsProvider);

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
          ],
        ),
      ),
    );
  }
}
