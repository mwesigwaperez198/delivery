import 'package:flutter/material.dart';
import '../../services/socket_service.dart';

class ActiveOrderScreen extends StatelessWidget {
  final Map<String, dynamic> orderData;
  final CourierSocketService socketService;

  const ActiveOrderScreen({
    super.key,
    required this.orderData,
    required this.socketService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Delivery'),
        backgroundColor: const Color(0xFF0E9594),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_bike, size: 80, color: Color(0xFF0E9594)),
            const SizedBox(height: 16),
            const Text('No active orders at the moment'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Dashboard'),
            )
          ],
        ),
      ),
    );
  }
}
