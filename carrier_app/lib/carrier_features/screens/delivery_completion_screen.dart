import 'package:flutter/material.dart';

class DeliveryCompletionScreen extends StatelessWidget {
  const DeliveryCompletionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 100, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              'Delivery Completed!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Return to Home'),
            )
          ],
        ),
      ),
    );
  }
}
