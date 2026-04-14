import 'package:flutter/material.dart';

class CollectionDetailsScreen extends StatelessWidget {
  final String collectionId;

  const CollectionDetailsScreen({super.key, required this.collectionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Collection: $collectionId')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(
            child: ListTile(
              title: Text('Question example'),
              subtitle: Text('Answer example'),
            ),
          ),
        ],
      ),
    );
  }
}
