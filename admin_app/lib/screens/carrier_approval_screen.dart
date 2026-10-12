import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CarrierApprovalScreen extends StatefulWidget {
  const CarrierApprovalScreen({super.key});

  @override
  State<CarrierApprovalScreen> createState() => _CarrierApprovalScreenState();
}

class _CarrierApprovalScreenState extends State<CarrierApprovalScreen> {
  final _apiService = ApiService();
  List<dynamic> _pendingCarriers = [];

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  Future<void> _loadPending() async {
    final res = await _apiService.getPendingCarriers();
    setState(() => _pendingCarriers = res);
  }

  Future<void> _approve(String id) async {
    await _apiService.updateCourierStatus(id, 'Available');
    _loadPending();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Courier Approvals')),
      body: ListView.builder(
        itemCount: _pendingCarriers.length,
        itemBuilder: (context, index) {
          final carrier = _pendingCarriers[index];
          return ListTile(
            title: Text(carrier['name']),
            subtitle: Text('${carrier['vehicleType']} • ${carrier['phoneNumber']}'),
            trailing: ElevatedButton(
              onPressed: () => _approve(carrier['_id']),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0E9594)),
              child: const Text('APPROVE'),
            ),
          );
        },
      ),
    );
  }
}
