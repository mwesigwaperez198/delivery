import 'package:flutter/material.dart';
import '../widgets/dynamic_hub_dashboard.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: DynamicHubDashboard(),
    );
  }
}
