import 'package:flutter/material.dart';
import '../widgets/dynamic_hub_dashboard.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.location_on, color: Color(0xFF0E9594), size: 32),
                Positioned(
                  top: 4,
                  child: const Icon(Icons.shopping_bag, color: Color(0xFF151515), size: 14),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dynamics',
                  style: TextStyle(
                    color: Color(0xFF151515),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const Text(
                  'Deliver Anything, Anywhere',
                  style: TextStyle(
                    color: Color(0xFF0E9594),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Color(0xFF151515)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF151515)),
            onPressed: () {},
          ),
        ],
      ),
      body: const DynamicHubDashboard(),
    );
  }
}
