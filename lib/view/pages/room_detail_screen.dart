import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RoomDetailScreen extends StatelessWidget {
  final String roomUrl;

  const RoomDetailScreen({
    super.key,
    required this.roomUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Room Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Room URL: $roomUrl',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
} 