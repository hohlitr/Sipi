import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../collections/providers/collections_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(userStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Achievements'),
            const SizedBox(height: 12),
            const Text('First collection created'),
            const Text('Started learning streak'),
            const SizedBox(height: 20),
            const Text('Study plans'),
            const SizedBox(height: 12),
            const Text('No plans yet'),
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
