import 'package:flutter/material.dart';
import '../models/merchant.dart';
import '../services/api_service.dart';
import '../screens/catalog_screen.dart';

class MerchantCategoryView extends StatefulWidget {
  final String category;
  const MerchantCategoryView({super.key, required this.category});

  @override
  State<MerchantCategoryView> createState() => _MerchantCategoryViewState();
}

class _MerchantCategoryViewState extends State<MerchantCategoryView> {
  final ApiService _api = ApiService();
  List<Merchant> _merchants = [];
  bool _isLoading = true;

  // Hardcoded fallback merchants per category — app works without server
  static const Map<String, List<Map<String, dynamic>>> _fallback = {
    'Food & Restaurants': [
      {'_id': 'm1', 'businessName': 'Chicken Palace', 'description': 'Best fried chicken in Kampala', 'category': 'Food & Restaurants', 'logo': '', 'location': {'landmark': 'Ntinda'}, 'rating': 4.8, 'reviewCount': 312, 'preparationTimeAverage': 15},
      {'_id': 'm2', 'businessName': 'Rolex Corner', 'description': 'Authentic Kampala street food', 'category': 'Food & Restaurants', 'logo': '', 'location': {'landmark': 'Wandegeya'}, 'rating': 4.7, 'reviewCount': 198, 'preparationTimeAverage': 8},
      {'_id': 'm3', 'businessName': 'Pizza Hub', 'description': 'Wood-fired pizzas & pasta', 'category': 'Food & Restaurants', 'logo': '', 'location': {'landmark': 'Kololo'}, 'rating': 4.5, 'reviewCount': 145, 'preparationTimeAverage': 25},
      {'_id': 'm4', 'businessName': 'Pilau Palace', 'description': 'Spiced rice & beef', 'category': 'Food & Restaurants', 'logo': '', 'location': {'landmark': 'Old Taxi Park'}, 'rating': 4.6, 'reviewCount': 220, 'preparationTimeAverage': 12},
    ],
    'Supermarkets': [
      {'_id': 'm5', 'businessName': 'Uchumi Express', 'description': 'Groceries delivered fast', 'category': 'Supermarkets', 'logo': '', 'location': {'landmark': 'Bugolobi'}, 'rating': 4.4, 'reviewCount': 89, 'preparationTimeAverage': 20},
      {'_id': 'm6', 'businessName': 'Nakumatt Kampala', 'description': 'Full supermarket range', 'category': 'Supermarkets', 'logo': '', 'location': {'landmark': 'Garden City'}, 'rating': 4.3, 'reviewCount': 67, 'preparationTimeAverage': 30},
    ],
    'Pharmacy': [
      {'_id': 'm7', 'businessName': 'City Pharmacy', 'description': 'Medicines & health products', 'category': 'Pharmacy', 'logo': '', 'location': {'landmark': 'Kampala Road'}, 'rating': 4.9, 'reviewCount': 412, 'preparationTimeAverage': 10},
      {'_id': 'm8', 'businessName': 'HealthPlus', 'description': 'Prescription & OTC drugs', 'category': 'Pharmacy', 'logo': '', 'location': {'landmark': 'Nakasero'}, 'rating': 4.7, 'reviewCount': 203, 'preparationTimeAverage': 12},
    ],
    'Electricals': [
      {'_id': 'm9', 'businessName': 'Tech Store UG', 'description': 'Electronics & accessories', 'category': 'Electricals', 'logo': '', 'location': {'landmark': 'Kikuubo'}, 'rating': 4.5, 'reviewCount': 78, 'preparationTimeAverage': 35},
    ],
    'Packages': [
      {'_id': 'm10', 'businessName': 'Dynamics Courier', 'description': 'Send anything anywhere', 'category': 'Packages', 'logo': '', 'location': {'landmark': 'Kampala'}, 'rating': 4.8, 'reviewCount': 560, 'preparationTimeAverage': 20},
    ],
  };

  @override
  void initState() {
    super.initState();
    _fetchMerchants();
  }

  Future<void> _fetchMerchants() async {
    setState(() => _isLoading = true);
    try {
      final res = await _api.getNearbyMerchants(0.3476, 32.5825, category: widget.category);
      if (res.statusCode == 200) {
        final List<dynamic> data = res.data;
        if (data.isNotEmpty) {
          setState(() {
            _merchants = data.map((j) => Merchant.fromJson(j)).toList();
            _isLoading = false;
          });
          return;
        }
      }
    } catch (_) {}
    // Use hardcoded fallback
    final fallbackList = _fallback[widget.category] ?? _fallback['Food & Restaurants']!;
    setState(() {
      _merchants = fallbackList.map((j) => Merchant.fromJson(j)).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFF0E9594)));

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _merchants.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _buildMerchantCard(_merchants[i], context),
    );
  }

  Widget _buildMerchantCard(Merchant merchant, BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CatalogScreen(merchant: merchant))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black08, blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF0E9594).withOpacity(0.08),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Stack(
                children: [
                  const Center(child: Icon(Icons.storefront_rounded, color: Color(0xFF0E9594), size: 48)),
                  Positioned(
                    top: 10, right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: [
                          const Icon(Icons.timer, size: 12, color: Color(0xFF0E9594)),
                          Text(' ${merchant.averagePrepTime} min', style: const TextStyle(fontSize: 11, color: Color(0xFF0E9594), fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(merchant.businessName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.amber.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            const Icon(Icons.star, size: 13, color: Colors.amber),
                            Text(' ${merchant.rating}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(merchant.description, style: TextStyle(color: Colors.grey[500], fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 13, color: Colors.grey),
                      Text(' ${merchant.landmark}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                      const Spacer(),
                      Text('${merchant.reviewCount} reviews', style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
