import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../collections/providers/collections_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(userStatsProvider);
    final achievements = ref.watch(achievementsProvider);
    final plans = ref.watch(studyPlansProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Achievements'),
            const SizedBox(height: 12),
            ...achievements.map((achievement) => Text('• ${achievement.title}')),
            const SizedBox(height: 20),
            const Text('Study plans'),
            const SizedBox(height: 12),
            if (plans.isEmpty)
              const Text('No plans yet')
            else
              ...plans.map((plan) => Text('• ${plan.collectionId}: ${(plan.targetProgress * 100).round()}% target')),
            const SizedBox(height: 20),
            const Text('Account summary'),
            const SizedBox(height: 12),
            Text('Collections: ${stats.totalCollections}'),
            Text('Cards: ${stats.totalCards}'),
            Text('Accuracy: ${(stats.accuracy * 100).round()}%'),
            const SizedBox(height: 20),
            const Text('Export options'),
            const SizedBox(height: 12),
            const Text('Collection export without personal stats will appear here.'),
          ],
        ),
      ),
    );
  }
}
