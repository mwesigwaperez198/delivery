import 'package:flutter/material.dart';
import '../screens/catalog_screen.dart';
import '../models/merchant.dart';
import '../services/api_service.dart';

class DynamicHubDashboard extends StatefulWidget {
  const DynamicHubDashboard({super.key});

  @override
  State<DynamicHubDashboard> createState() => _DynamicHubDashboardState();
}

class _DynamicHubDashboardState extends State<DynamicHubDashboard> {
  String _selectedAddress = 'Current Location';
  final TextEditingController _aiController = TextEditingController();
  final ApiService _api = ApiService();
  List<Merchant> _nearbyMerchants = [];

  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.restaurant_rounded, 'label': 'Food', 'color': Color(0xFFFF6B35)},
    {'icon': Icons.shopping_basket_rounded, 'label': 'Groceries', 'color': Color(0xFF4CAF50)},
    {'icon': Icons.local_pharmacy_rounded, 'label': 'Pharmacy', 'color': Color(0xFF2196F3)},
    {'icon': Icons.local_bar_rounded, 'label': 'Drinks', 'color': Color(0xFF9C27B0)},
    {'icon': Icons.delivery_dining_rounded, 'label': 'Send Anything', 'color': Color(0xFF0E9594)},
    {'icon': Icons.storefront_rounded, 'label': 'Shop', 'color': Color(0xFFFF9800)},
    {'icon': Icons.inventory_2_rounded, 'label': 'Parcel', 'color': Color(0xFF795548)},
    {'icon': Icons.local_fire_department_rounded, 'label': 'Gas', 'color': Color(0xFFF44336)},
  ];

  final List<Map<String, dynamic>> _stories = [
    {'label': '50% Food', 'color': Color(0xFFFF6B35)},
    {'label': 'Free Delivery', 'color': Color(0xFF0E9594)},
    {'label': 'New: Gas', 'color': Color(0xFFF44336)},
    {'label': 'Rolex Deal', 'color': Color(0xFFF5DF4D)},
    {'label': 'Pharmacy', 'color': Color(0xFF2196F3)},
  ];

  final List<Map<String, dynamic>> _recentOrders = [
    {'name': 'Chicken & Chips', 'vendor': 'KFC Kampala', 'price': 'UGX 25,000'},
    {'name': 'Panadol x2', 'vendor': 'Kampala Pharmacy', 'price': 'UGX 4,000'},
    {'name': 'Milk + Bread', 'vendor': 'Uchumi', 'price': 'UGX 12,000'},
  ];

  @override
  void initState() {
    super.initState();
    _loadNearby();
  }

  Future<void> _loadNearby() async {
    try {
      final res = await _api.getNearbyMerchants(0.3476, 32.5825);
      if (res.statusCode == 200) {
        final List<dynamic> data = res.data;
        setState(() => _nearbyMerchants = data.map((j) => Merchant.fromJson(j)).take(6).toList());
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        SliverToBoxAdapter(child: _buildStoriesBar()),
        SliverToBoxAdapter(child: _buildCategoryGrid()),
        SliverToBoxAdapter(child: _buildAIBox()),
        SliverToBoxAdapter(child: _buildNearYou()),
        SliverToBoxAdapter(child: _buildReorder()),
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(child: Text('Developed by Novara', style: TextStyle(color: Colors.grey, fontSize: 11, letterSpacing: 0.5))),
        )),
      ],
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: const Color(0xFF0E9594),
      expandedHeight: 120,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: const Color(0xFF0E9594),
          padding: const EdgeInsets.fromLTRB(16, 48, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Address selector
              GestureDetector(
                onTap: _showAddressPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFFF5DF4D), size: 18),
                      const SizedBox(width: 6),
                      Text(
                        _selectedAddress,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search food, shops, parcels...',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF0E9594), size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddressPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          const Text('Deliver to', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          for (final option in ['Current Location', 'Home', 'Work'])
            ListTile(
              leading: Icon(
                option == 'Current Location' ? Icons.my_location : option == 'Home' ? Icons.home : Icons.work,
                color: const Color(0xFF0E9594),
              ),
              title: Text(option),
              onTap: () {
                setState(() => _selectedAddress = option);
                Navigator.pop(context);
              },
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStoriesBar() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        itemCount: _stories.length,
        itemBuilder: (context, i) {
          final s = _stories[i];
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [s['color'] as Color, (s['color'] as Color).withOpacity(0.6)],
                    ),
                    border: Border.all(color: const Color(0xFF0E9594), width: 2),
                  ),
                  child: const Icon(Icons.local_offer, color: Colors.white, size: 24),
                ),
                const SizedBox(height: 4),
                Text(s['label'] as String, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('What do you need?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.85,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, i) {
              final cat = _categories[i];
              return GestureDetector(
                onTap: () {},
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: (cat['color'] as Color).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(cat['icon'] as IconData, color: cat['color'] as Color, size: 26),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cat['label'] as String,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAIBox() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F2D2E), Color(0xFF0E9594)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5DF4D),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF151515))),
              ),
              const SizedBox(width: 8),
              const Text('What do you need?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _aiController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'e.g. "bring me Panadol and milk in 20min"',
                hintStyle: TextStyle(color: Colors.white54, fontSize: 12),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send_rounded, color: Color(0xFFF5DF4D)),
                  onPressed: () {},
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearYou() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Near You', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton(onPressed: () {}, child: const Text('See all', style: TextStyle(color: Color(0xFF0E9594)))),
            ],
          ),
          const SizedBox(height: 8),
          _nearbyMerchants.isEmpty
              ? _buildNearYouPlaceholders()
              : SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _nearbyMerchants.length,
                    itemBuilder: (context, i) => _buildVendorCard(_nearbyMerchants[i]),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildNearYouPlaceholders() {
    final placeholders = [
      {'name': 'Chicken Palace', 'eta': '15 min', 'rating': '4.8', 'category': 'Food'},
      {'name': 'Uchumi Express', 'eta': '20 min', 'rating': '4.5', 'category': 'Groceries'},
      {'name': 'City Pharmacy', 'eta': '12 min', 'rating': '4.9', 'category': 'Pharmacy'},
      {'name': 'Rolex Corner', 'eta': '8 min', 'rating': '4.7', 'category': 'Food'},
      {'name': 'Drinks Hub', 'eta': '18 min', 'rating': '4.3', 'category': 'Drinks'},
      {'name': 'Tech Store', 'eta': '25 min', 'rating': '4.6', 'category': 'Electricals'},
    ];
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: placeholders.length,
        itemBuilder: (context, i) {
          final p = placeholders[i];
          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E9594).withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: const Center(child: Icon(Icons.storefront, color: Color(0xFF0E9594), size: 36)),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 12, color: Colors.amber),
                          Text(' ${p['rating']}', style: const TextStyle(fontSize: 10)),
                          const Spacer(),
                          const Icon(Icons.timer, size: 12, color: Color(0xFF0E9594)),
                          Text(' ${p['eta']}', style: const TextStyle(fontSize: 10, color: Color(0xFF0E9594))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVendorCard(Merchant merchant) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CatalogScreen(merchant: merchant))),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFF0E9594).withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: const Center(child: Icon(Icons.storefront, color: Color(0xFF0E9594), size: 36)),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(merchant.businessName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                      Text(' ${merchant.rating}', style: const TextStyle(fontSize: 10)),
                      const Spacer(),
                      const Icon(Icons.timer, size: 12, color: Color(0xFF0E9594)),
                      Text(' ${merchant.averagePrepTime}m', style: const TextStyle(fontSize: 10, color: Color(0xFF0E9594))),
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

  Widget _buildReorder() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Re-order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          ..._recentOrders.map((order) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6)],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E9594).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.fastfood_rounded, color: Color(0xFF0E9594), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text(order['vendor']!, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(order['price']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0E9594))),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5DF4D),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Order Again', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF151515))),
                    ),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
