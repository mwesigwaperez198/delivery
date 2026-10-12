import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'services/socket_service.dart';
import 'services/courier_tracking_service.dart';
import 'carrier_features/screens/active_order_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CourierTrackingService.initializeService();
  runApp(const BodaCarrierApp());
}

class BodaCarrierApp extends StatelessWidget {
  const BodaCarrierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Novara Boda Carrier',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF0E9594), // Electrical Teal
        scaffoldBackgroundColor: const Color(0xFF151515), // Charcoal
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF0E9594),
          onPrimary: Colors.white,
          secondary: Color(0xFFF5DF4D), // Accent Yellow
          onSecondary: Color(0xFF151515),
          surface: Color(0xFF1E1E1E),
          background: Color(0xFF151515),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF151515),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const CourierDashboard(),
    );
  }
}

class CourierDashboard extends StatefulWidget {
  const CourierDashboard({super.key});

  @override
  State<CourierDashboard> createState() => _CourierDashboardState();
}

class _CourierDashboardState extends State<CourierDashboard> {
  final CourierSocketService _socket = CourierSocketService();
  bool _isServiceRunning = false;
  Map<String, dynamic>? _activeAssignment;
  final String _courierId = "courier_boda_101";

  @override
  void initState() {
    super.initState();
    _checkServiceStatus();
    _socket.connect(_courierId);
    _socket.onNewAssignment = (data) {
      setState(() => _activeAssignment = data);
      _showAssignmentDialog(data);
    };
  }

  Future<void> _checkServiceStatus() async {
    final isRunning = await FlutterBackgroundService().isRunning();
    setState(() => _isServiceRunning = isRunning);
  }

  Future<void> _toggleDuty() async {
    final service = FlutterBackgroundService();
    if (await service.isRunning()) {
      service.invoke("stopService");
    } else {
      bool success = await service.startService();
      if (!success) {
        // Handle error if service fails to start
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to start tracking service")),
        );
      }
    }
    
    // Give time for service to start/stop before checking status
    await Future.delayed(const Duration(milliseconds: 1000));
    _checkServiceStatus();
  }

  void _showAssignmentDialog(Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: const Color(0xFF1D1E33),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "NEW DELIVERY REQUEST",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.store, color: Colors.amber, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("PICKUP", style: TextStyle(color: Colors.white54, fontSize: 10)),
                      Text(data['pickup'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.redAccent, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("DELIVERY", style: TextStyle(color: Colors.white54, fontSize: 10)),
                      Text(data['delivery'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      setState(() => _activeAssignment = null);
                      Navigator.pop(context);
                    },
                    child: const Text("DECLINE", style: TextStyle(color: Colors.white70)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ActiveOrderScreen(
                            orderData: data,
                            socketService: _socket,
                          ),
                        ),
                      ).then((_) => setState(() => _activeAssignment = null));
                    },
                    child: const Text("ACCEPT", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("HELLO, MUSA", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      Text(
                        _isServiceRunning ? "Status: Online" : "Status: Offline",
                        style: TextStyle(
                          color: _isServiceRunning ? Colors.greenAccent : Colors.white54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xFF1D1E33),
                    child: Icon(Icons.person, color: Colors.amber),
                  ),
                ],
              ),
              const Spacer(),
              _buildStatsRow(),
              const Spacer(),
              GestureDetector(
                onTap: _toggleDuty,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isServiceRunning ? Colors.redAccent.withOpacity(0.1) : Colors.amber.withOpacity(0.1),
                    border: Border.all(
                      color: _isServiceRunning ? Colors.redAccent : Colors.amber,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (_isServiceRunning ? Colors.redAccent : Colors.amber).withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isServiceRunning ? Icons.power_settings_new : Icons.electric_bolt,
                        size: 60,
                        color: _isServiceRunning ? Colors.redAccent : Colors.amber,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _isServiceRunning ? "GO OFFLINE" : "GO ONLINE",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _isServiceRunning ? Colors.redAccent : Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              if (_activeAssignment != null)
                _buildActiveAssignmentBanner()
              else
                _buildWaitingBanner(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _statItem("Earnings", "UGX 45k", Icons.payments, Colors.greenAccent),
        _statItem("Deliveries", "12", Icons.inventory_2, Colors.blueAccent),
        _statItem("Rating", "4.9", Icons.star, Colors.amber),
      ],
    );
  }

  Widget _statItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }

  Widget _buildActiveAssignmentBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.black),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "You have a pending delivery request",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () => _showAssignmentDialog(_activeAssignment!),
            child: const Text("VIEW", style: TextStyle(color: Colors.black, decoration: TextDecoration.underline)),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(_isServiceRunning ? Colors.amber : Colors.white24),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            _isServiceRunning ? "Scanning for nearby orders..." : "Go online to receive orders",
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
