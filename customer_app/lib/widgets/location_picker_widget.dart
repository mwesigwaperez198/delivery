import 'package:flutter/material.dart';

// Simple address picker — no native location package needed.
// Works on web, Android, iOS, desktop without permission issues.
// When Google Maps key is configured, swap the placeholder for a real GoogleMap widget.
class LocationPickerWidget extends StatefulWidget {
  final Function(String address) onLocationSelected;

  const LocationPickerWidget({super.key, required this.onLocationSelected});

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  final TextEditingController _controller = TextEditingController();

  final List<String> _suggestions = [
    'Ntinda, opposite Shell petrol station',
    'Wandegeya, near Makerere gate',
    'Kololo, Acacia Avenue',
    'Nakasero, near Serena Hotel',
    'Bugolobi, Shell Bugolobi',
    'Kireka, Kampala-Jinja Road',
    'Naalya, Naalya Estate',
    'Najjera, Najjera 1',
  ];

  List<String> _filtered = [];

  void _onChanged(String val) {
    widget.onLocationSelected(val);
    setState(() {
      _filtered = val.isEmpty
          ? []
          : _suggestions.where((s) => s.toLowerCase().contains(val.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6)],
          ),
          child: TextField(
            controller: _controller,
            onChanged: _onChanged,
            decoration: InputDecoration(
              hintText: 'e.g. Ntinda, opposite Shell petrol station',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
              prefixIcon: const Icon(Icons.location_on_rounded, color: Color(0xFF0E9594)),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _controller.clear();
                        _onChanged('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),
        ),
        if (_filtered.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6)],
            ),
            child: Column(
              children: _filtered.map((s) => ListTile(
                dense: true,
                leading: const Icon(Icons.location_on, color: Color(0xFF0E9594), size: 18),
                title: Text(s, style: const TextStyle(fontSize: 13)),
                onTap: () {
                  _controller.text = s;
                  widget.onLocationSelected(s);
                  setState(() => _filtered = []);
                },
              )).toList(),
            ),
          ),
        const SizedBox(height: 12),
        // Map placeholder — replace with GoogleMap widget once API key is set
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: const Color(0xFF0E9594).withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF0E9594).withOpacity(0.2)),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map_rounded, size: 40, color: Color(0xFF0E9594)),
                SizedBox(height: 8),
                Text('Map preview', style: TextStyle(color: Color(0xFF0E9594), fontWeight: FontWeight.w500)),
                Text('Enter address above to set delivery point', style: TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
