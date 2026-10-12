import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/socket_service.dart';

class LiveOpsMap extends StatefulWidget {
  const LiveOpsMap({super.key});

  @override
  State<LiveOpsMap> createState() => _LiveOpsMapState();
}

class _LiveOpsMapState extends State<LiveOpsMap> {
  final Completer<GoogleMapController> _controller = Completer();
  final AdminSocketService _socketService = AdminSocketService();
  
  // Track couriers by ID
  final Map<String, Marker> _courierMarkers = {};
  
  static const CameraPosition _kampalaCenter = CameraPosition(
    target: LatLng(0.3476, 32.5825),
    zoom: 13,
  );

  @override
  void initState() {
    super.initState();
    _initSocket();
  }

  void _initSocket() {
    _socketService.connect("admin_map_view");
    
    _socketService.onLocationUpdate = (data) {
      final courierId = data['courierId'];
      final lat = data['latitude'] as double;
      final lng = data['longitude'] as double;
      final battery = data['battery'] as int;

      if (mounted) {
        setState(() {
          _courierMarkers[courierId] = Marker(
            markerId: MarkerId(courierId),
            position: LatLng(lat, lng),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              battery < 20 ? BitmapDescriptor.hueRed : BitmapDescriptor.hueAzure
            ),
            infoWindow: InfoWindow(
              title: 'Courier: ${courierId.substring(courierId.length - 4)}',
              snippet: 'Battery: $battery% | Status: Online',
            ),
          );
        });
      }
    };
  }

  @override
  void dispose() {
    _socketService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LIVE LOGISTICS HUB', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: const Color(0xFF0A0E21),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Chip(
              label: Text('${_courierMarkers.length} Active Bodas', style: const TextStyle(fontSize: 10)),
              backgroundColor: Colors.blueAccent.withOpacity(0.2),
            ),
          )
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: _kampalaCenter,
        onMapCreated: (controller) => _controller.complete(controller),
        markers: _courierMarkers.values.toSet(),
        myLocationButtonEnabled: false,
        style: _darkMapStyle, // Note: You'd typically load this from assets
      ),
    );
  }

  // Simplified dark mode style for Admin Dashboard
  static const String _darkMapStyle = ''; 
}
