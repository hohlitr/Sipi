import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../collections/providers/collections_providers.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String collectionId;

  const QuizScreen({super.key, required this.collectionId});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int currentIndex = 0;
  bool answerVisible = false;

  @override
  Widget build(BuildContext context) {
    final cards = ref.watch(weakCardsProvider(widget.collectionId));

    if (cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: Text('No cards available for quiz yet.')),
      );
    }

    final card = cards[currentIndex];

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Card ${currentIndex + 1} of ${cards.length}'),
            const SizedBox(height: 16),
            Text(card.question, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            if (answerVisible) ...[
              Text(card.answer, style: Theme.of(context).textTheme.titleLarge),
              if ((card.note ?? '').isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(card.note!),
              ],
            ],
            const Spacer(),
            if (!answerVisible)
              FilledButton(
                onPressed: () => setState(() => answerVisible = true),
                child: const Text('Show answer'),
              )
            else ...[
              FilledButton(
                onPressed: () => _submit(true),
                child: const Text('I was correct'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => _submit(false),
                child: const Text('I was wrong'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _submit(bool correct) {
    ref.read(collectionsRepositoryProvider).recordQuizAnswer(
          collectionId: widget.collectionId,
          cardId: ref.read(weakCardsProvider(widget.collectionId))[currentIndex].id,
          correct: correct,
        );
    ref.invalidate(cardsForCollectionProvider(widget.collectionId));
    ref.invalidate(weakCardsProvider(widget.collectionId));
    ref.invalidate(userStatsProvider);

    final cards = ref.read(weakCardsProvider(widget.collectionId));
    if (currentIndex + 1 >= cards.length) {
      if (mounted) {
        Navigator.of(context).pop();
      }
      return;
    }

    setState(() {
      currentIndex += 1;
      answerVisible = false;
    });
  }
}
