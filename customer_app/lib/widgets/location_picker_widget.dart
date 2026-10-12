import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class LocationPickerWidget extends StatefulWidget {
  final Function(LatLng, String) onLocationSelected;

  const LocationPickerWidget({super.key, required this.onLocationSelected});

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(0.3476, 32.5825); // Kampala default
  final Set<Marker> _markers = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    locationData = await location.getLocation();
    setState(() {
      _currentPosition = LatLng(locationData.latitude!, locationData.longitude!);
      _updateMarker(_currentPosition);
      _loading = false;
    });

    _mapController?.animateCamera(CameraUpdate.newLatLng(_currentPosition));
  }

  void _updateMarker(LatLng position) {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          draggable: true,
          onDragEnd: (newPosition) {
            setState(() {
              _currentPosition = newPosition;
            });
            widget.onLocationSelected(newPosition, "Selected Location");
          },
        ),
      );
    });
    widget.onLocationSelected(position, "Selected Location");
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 15,
            ),
            onMapCreated: (controller) => _mapController = controller,
            markers: _markers,
            onTap: (position) {
              setState(() {
                _currentPosition = position;
                _updateMarker(position);
              });
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.white.withOpacity(0.8),
              child: const Text(
                'Tap map to set delivery pin',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
