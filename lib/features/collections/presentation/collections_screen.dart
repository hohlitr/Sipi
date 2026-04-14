import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CollectionsScreen extends StatelessWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Biology basics'),
            subtitle: const Text('12 cards'),
            onTap: () => context.go('/collections/demo'),
          ),
        ],
      ),
    );
  }
}
