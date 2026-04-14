import 'package:flutter/material.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Overall progress'),
            SizedBox(height: 12),
            LinearProgressIndicator(value: 0.35),
            SizedBox(height: 12),
            Text('Collections and test statistics will appear here.'),
          ],
        ),
      ),
    );
  }
}
