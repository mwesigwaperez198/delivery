import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isListening = false;

  final List<Map<String, dynamic>> _suggestions = [
    {'icon': Icons.umbrella_rounded, 'text': "It's raining — want a boda with raincoat?", 'color': Color(0xFF2196F3)},
    {'icon': Icons.lunch_dining_rounded, 'text': 'Lunch time! Rolex near you from UGX 3,000', 'color': Color(0xFFFF6B35)},
    {'icon': Icons.local_pharmacy_rounded, 'text': 'Reorder your Panadol from last week?', 'color': Color(0xFF4CAF50)},
  ];

  final List<String> _trending = ['Rolex', 'Chicken', 'Panadol', 'Milk', 'Airtime', 'Gas', 'Pizza', 'Juice'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSmartSuggestions(),
                    const SizedBox(height: 24),
                    _buildImageSearch(),
                    const SizedBox(height: 24),
                    _buildTrending(),
                    const SizedBox(height: 24),
                    Center(child: Text('Developed by Novara', style: TextStyle(color: Colors.grey, fontSize: 11, letterSpacing: 0.5))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      color: const Color(0xFF0E9594),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Search', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Voice · Text · Image', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search anything in Kampala...',
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF0E9594), size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Voice button
              GestureDetector(
                onTap: () => setState(() => _isListening = !_isListening),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: _isListening ? const Color(0xFFF5DF4D) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: _isListening ? const Color(0xFF151515) : const Color(0xFF0E9594),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Image search button
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF0E9594)),
                ),
              ),
            ],
          ),
          if (_isListening) ...[
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.graphic_eq, color: Color(0xFFF5DF4D), size: 16),
                SizedBox(width: 6),
                Text('Listening...', style: TextStyle(color: Color(0xFFF5DF4D), fontSize: 12)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSmartSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Smart Suggestions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 10),
        ..._suggestions.map((s) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6)],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (s['color'] as Color).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(s['icon'] as IconData, color: s['color'] as Color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(s['text'] as String, style: const TextStyle(fontSize: 13))),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildImageSearch() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F2D2E), Color(0xFF0E9594)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.document_scanner_rounded, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Snap & Search', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  SizedBox(height: 2),
                  Text('Photo a receipt, drug, or document — we find it', style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.camera_alt, color: Color(0xFFF5DF4D)),
          ],
        ),
      ),
    );
  }

  Widget _buildTrending() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Trending in Kampala', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _trending.map((t) => GestureDetector(
            onTap: () => _searchController.text = t,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF0E9594).withOpacity(0.3)),
              ),
              child: Text(t, style: const TextStyle(fontSize: 13, color: Color(0xFF0E9594), fontWeight: FontWeight.w500)),
            ),
          )).toList(),
        ),
      ],
    );
  }
}
