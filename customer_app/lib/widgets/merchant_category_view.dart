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
  final ApiService _apiService = ApiService();
  List<Merchant> _merchants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMerchants();
  }

  Future<void> _fetchMerchants() async {
    setState(() => _isLoading = true);
    try {
      // Using hardcoded Kampala coords for now as in original views
      final response = await _apiService.getNearbyMerchants(0.3476, 32.5825, category: widget.category);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        setState(() {
          _merchants = data.map((json) => Merchant.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_merchants.isEmpty) return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.storefront, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("No vendors found in ${widget.category}", 
            style: TextStyle(color: Colors.grey[600], fontSize: 16)),
        ],
      )
    );

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _merchants.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final merchant = _merchants[index];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CatalogScreen(merchant: merchant)),
          ),
          child: Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 140,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 50, color: Colors.grey),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            merchant.businessName,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star, size: 16, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(merchant.rating.toString()),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        merchant.landmark,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.timer_outlined, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text('${merchant.averagePrepTime} mins', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          const Spacer(),
                          const Text('View Store', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
