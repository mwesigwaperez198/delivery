import 'package:flutter/material.dart';
import 'services/monitoring_service.dart';
import 'services/socket_service.dart';
import 'screens/live_ops_map.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final monitor = MonitoringService();
  await monitor.trackHealth('online');
  runApp(const AdminControlApp());
}

class AdminControlApp extends StatelessWidget {
  const AdminControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Novara Admin Ops',
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
      ),
      home: const MainNavigationHolder(),
    );
  }
}

class MainNavigationHolder extends StatefulWidget {
  const MainNavigationHolder({super.key});

  @override
  State<MainNavigationHolder> createState() => _MainNavigationHolderState();
}

class _MainNavigationHolderState extends State<MainNavigationHolder> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const DashboardScreen(),
    const LiveOpsMap(),
    const WorkforceScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: const Color(0xFF1D1E33),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Live Map'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Workforce'),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final MonitoringService _monitor = MonitoringService();
  final AdminSocketService _socketService = AdminSocketService();
  Map<String, dynamic>? _summary;
  List<String> _liveAlerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    _initSocket();
  }

  void _initSocket() {
    _socketService.connect("admin_001");
    
    _socketService.onSummaryUpdate = (data) {
      if (mounted) setState(() => _summary = data);
    };

    _socketService.onDispatchEvent = (data) {
      _addAlert("Order ${data['payload']['orderId']} assigned to Courier.");
    };

    // New listener for Behavioral Anomalies
    _socketService.socket.on('behavior_alert', (data) {
      if (mounted) {
        _addAlert("ALARM: ${data['courierName']} - ${data['anomalyType']}");
      }
    });
  }

  void _addAlert(String message) {
    setState(() {
      _liveAlerts.insert(0, message);
      if (_liveAlerts.length > 5) _liveAlerts.removeLast();
    });
  }

  @override
  void dispose() {
    _socketService.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    setState(() => _isLoading = true);
    final data = await _monitor.getSystemSummary();
    setState(() {
      _summary = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final finance = _summary?['finance'] ?? {};
    final behavior = _summary?['behavior'] ?? {};
    final monitor = _summary?['monitoring'] ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('UGANDA OPS: DASHBOARD', style: TextStyle(letterSpacing: 1.2, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchInitialData)],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFinanceOverview(finance),
                  const SizedBox(height: 24),
                  _buildSectionTitle('REAL-TIME BEHAVIOR FEED'),
                  const SizedBox(height: 10),
                  ..._liveAlerts.map((alert) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.redAccent.withOpacity(0.3))),
                    child: Row(children: [const Icon(Icons.warning, color: Colors.redAccent, size: 16), const SizedBox(width: 10), Expanded(child: Text(alert, style: const TextStyle(fontSize: 12, color: Colors.redAccent)))]),
                  )).toList(),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: _buildMetricBox('Mood', behavior['systemMood'] ?? 'N/A', Icons.face, Colors.pinkAccent)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildMetricBox('Completion', behavior['completionRate'] ?? '0%', Icons.task_alt, Colors.greenAccent)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildMetricTile('System Health', monitor['healthScore'] ?? 'Optimal', Icons.sensors, Colors.cyanAccent),
                  _buildMetricTile('Top Neighborhood', monitor['topNeighborhood'] ?? 'N/A', Icons.location_on, Colors.deepOrangeAccent),
                ],
              ),
            ),
    );
  }

  Widget _buildFinanceOverview(Map<dynamic, dynamic> finance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF0D47A1)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text('NET REVENUE', style: TextStyle(color: Colors.white70, fontSize: 12)),
          Text('${finance['netRevenue'] ?? 0} ${finance['currency'] ?? 'UGX'}', 
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildMetricBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1D1E33), borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon, Color color) {
    return Card(
      color: const Color(0xFF1D1E33),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label, style: const TextStyle(fontSize: 13)),
        trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class WorkforceScreen extends StatefulWidget {
  const WorkforceScreen({super.key});

  @override
  State<WorkforceScreen> createState() => _WorkforceScreenState();
}

class _WorkforceScreenState extends State<WorkforceScreen> {
  final MonitoringService _monitor = MonitoringService();
  List<dynamic>? _workforce;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkforce();
  }

  Future<void> _loadWorkforce() async {
    setState(() => _isLoading = true);
    final data = await _monitor.getWorkforceOverview();
    setState(() {
      _workforce = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WORKFORCE & CHARACTER'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _workforce?.length ?? 0,
              itemBuilder: (context, index) {
                final courier = _workforce![index];
                final char = courier['character'];
                
                return Card(
                  color: const Color(0xFF1D1E33),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(courier['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            _buildStatusBadge(courier['status']),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.electric_bolt, size: 14, color: Colors.amber),
                            Text(' ${courier['battery']}% Battery', style: const TextStyle(fontSize: 12, color: Colors.white70)),
                            const SizedBox(width: 16),
                            const Icon(Icons.directions_bike, size: 14, color: Colors.blueAccent),
                            Text(' ${courier['vehicle']}', style: const TextStyle(fontSize: 12, color: Colors.white70)),
                          ],
                        ),
                        const Divider(height: 24, color: Colors.white10),
                        const Text('CHARACTER PROFILE', style: TextStyle(fontSize: 10, color: Colors.white38, letterSpacing: 1)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _charStat('Completion', '${char['completionRate']}%'),
                            _charStat('Reliability', char['reliability']),
                            _charStat('Current Mood', char['moodHistory'].isEmpty ? 'N/A' : char['moodHistory'].last),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: courier['isActivated'] == true ? Colors.redAccent.withOpacity(0.8) : Colors.green.withOpacity(0.8),
                                ),
                                onPressed: () async {
                                  final success = await _monitor.activateCourier(courier['id'], !(courier['isActivated'] == true));
                                  if (success) _loadWorkforce();
                                },
                                child: Text(
                                  courier['isActivated'] == true ? 'DEACTIVATE' : 'ACTIVATE BODA',
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey.shade800),
                                onPressed: () {
                                  // Manual Duty Assignment Logic
                                },
                                child: const Text('ASSIGN DUTY', style: TextStyle(color: Colors.white, fontSize: 12)),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = status == 'Available' ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
      child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _charStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
      ],
    );
  }
}
