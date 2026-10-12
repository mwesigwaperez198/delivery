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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  Future<void> _loadPending() async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiService.getPendingCarriers();
      setState(() => _pendingCarriers = res);
    } catch (e) {
      debugPrint('Error loading carriers: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _approve(String id) async {
    try {
      await _apiService.updateCourierStatus(id, 'Available');
      _loadPending();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Courier approved and activated!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to approve: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151515),
      appBar: AppBar(
        title: const Text('Dynamics Fleet Manager'),
        backgroundColor: const Color(0xFF0E9594),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadPending,
        child: _isLoading && _pendingCarriers.isEmpty
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFF5DF4D)))
            : _pendingCarriers.isEmpty
                ? const Center(
                    child: Text(
                      'No pending applications',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _pendingCarriers.length,
                    itemBuilder: (context, index) {
                      final carrier = _pendingCarriers[index];
                      return Card(
                        color: Colors.white.withOpacity(0.05),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFF0E9594), width: 0.5),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFF0E9594),
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(
                            carrier['name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${carrier['vehicleType']} • ${carrier['phoneNumber']}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: ElevatedButton(
                            onPressed: () => _approve(carrier['_id']),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF5DF4D),
                              foregroundColor: const Color(0xFF151515),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('APPROVE'),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
