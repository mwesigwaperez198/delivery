import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/merchant.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/cart_provider.dart';
import 'checkout_screen.dart';

class CatalogScreen extends StatefulWidget {
  final Merchant merchant;
  const CatalogScreen({super.key, required this.merchant});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final ApiService _api = ApiService();
  List<Product> _products = [];
  List<Product> _filtered = [];
  bool _isLoading = true;
  String _searchQuery = '';

  // Hardcoded fallback products shown when server is unreachable
  final List<Map<String, dynamic>> _fallbackProducts = [
    {'_id': 'p1', 'name': 'Chicken & Chips', 'description': 'Crispy fried chicken with chips', 'price': 22000, 'image': '', 'category': 'Food', 'isAvailable': true},
    {'_id': 'p2', 'name': 'Rolex (Egg Roll)', 'description': 'Classic Kampala street rolex', 'price': 4000, 'image': '', 'category': 'Food', 'isAvailable': true},
    {'_id': 'p3', 'name': 'Beef Burger', 'description': 'Juicy beef burger with fries', 'price': 18000, 'image': '', 'category': 'Food', 'isAvailable': true},
    {'_id': 'p4', 'name': 'Fresh Juice (1L)', 'description': 'Passion fruit or mango', 'price': 8000, 'image': '', 'category': 'Drinks', 'isAvailable': true},
    {'_id': 'p5', 'name': 'Pilau Rice', 'description': 'Spiced rice with beef', 'price': 12000, 'image': '', 'category': 'Food', 'isAvailable': true},
    {'_id': 'p6', 'name': 'Soda (500ml)', 'description': 'Coke, Fanta, Sprite', 'price': 3000, 'image': '', 'category': 'Drinks', 'isAvailable': true},
  ];

  @override
  void initState() {
    super.initState();
    _fetchCatalog();
  }

  Future<void> _fetchCatalog() async {
    setState(() => _isLoading = true);
    try {
      final res = await _api.getMerchantCatalog(widget.merchant.id);
      if (res.statusCode == 200) {
        final List<dynamic> raw = res.data['products'] ?? res.data;
        setState(() {
          _products = raw.map((j) => Product.fromJson(j)).toList();
          _filtered = _products;
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}
    // Fallback to hardcoded data so app works offline / during dev
    setState(() {
      _products = _fallbackProducts.map((j) => Product.fromJson(j)).toList();
      _filtered = _products;
      _isLoading = false;
    });
  }

  void _onSearch(String q) {
    setState(() {
      _searchQuery = q;
      _filtered = q.isEmpty
          ? _products
          : _products.where((p) => p.name.toLowerCase().contains(q.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final cartCount = cart.itemCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(cart, cartCount),
          SliverToBoxAdapter(child: _buildMerchantInfo()),
          SliverToBoxAdapter(child: _buildSearchBar()),
          _isLoading
              ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: Color(0xFF0E9594))))
              : _filtered.isEmpty
                  ? SliverFillRemaining(child: _buildEmpty())
                  : SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) => _buildProductCard(_filtered[i], cart),
                          childCount: _filtered.length,
                        ),
                      ),
                    ),
          SliverToBoxAdapter(child: _buildFooter()),
        ],
      ),
      bottomNavigationBar: cartCount > 0 ? _buildCartBar(cart) : null,
    );
  }

  Widget _buildAppBar(CartProvider cart, int cartCount) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: const Color(0xFF0E9594),
      foregroundColor: Colors.white,
      title: Text(widget.merchant.businessName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_rounded, color: Colors.white),
              onPressed: cartCount > 0
                  ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen()))
                  : null,
            ),
            if (cartCount > 0)
              Positioned(
                right: 6, top: 6,
                child: Container(
                  width: 18, height: 18,
                  decoration: const BoxDecoration(color: Color(0xFFF5DF4D), shape: BoxShape.circle),
                  child: Center(child: Text('$cartCount', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF151515)))),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildMerchantInfo() {
    return Container(
      color: const Color(0xFF0E9594),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.merchant.description.isNotEmpty ? widget.merchant.description : widget.merchant.category,
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFF5DF4D), size: 14),
                    Text(' ${widget.merchant.rating}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                    const SizedBox(width: 12),
                    const Icon(Icons.timer, color: Colors.white70, size: 14),
                    Text(' ${widget.merchant.averagePrepTime} min', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(width: 12),
                    const Icon(Icons.location_on, color: Colors.white70, size: 14),
                    Expanded(child: Text(' ${widget.merchant.landmark}', style: const TextStyle(color: Colors.white70, fontSize: 12), overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black08, blurRadius: 6)],
      ),
      child: TextField(
        onChanged: _onSearch,
        decoration: InputDecoration(
          hintText: 'Search menu...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF0E9594), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product, CartProvider cart) {
    final qty = cart.getProductQuantity(product.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black08, blurRadius: 8)],
      ),
      child: Row(
        children: [
          // Product image placeholder
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFF0E9594).withOpacity(0.08),
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            ),
            child: const Icon(Icons.fastfood_rounded, color: Color(0xFF0E9594), size: 36),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                      if (!product.isAvailable)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                          child: const Text('Out of stock', style: TextStyle(color: Colors.red, fontSize: 9)),
                        ),
                    ],
                  ),
                  if (product.description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(product.description, style: TextStyle(color: Colors.grey[500], fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('UGX ${product.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0E9594), fontSize: 14)),
                      if (product.isAvailable)
                        qty == 0
                            ? GestureDetector(
                                onTap: () => cart.addItem(product, widget.merchant.id),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0E9594),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text('Add', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              )
                            : Row(
                                children: [
                                  _qtyBtn(Icons.remove, () => cart.removeItem(product.id)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  ),
                                  _qtyBtn(Icons.add, () => cart.addItem(product, widget.merchant.id)),
                                ],
                              ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFF0E9594).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF0E9594)),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text('No items found for "$_searchQuery"', style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildCartBar(CartProvider cart) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen())),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF0E9594),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: const Color(0xFF0E9594).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
              child: Text('${cart.itemCount}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('View Cart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15))),
            Text('UGX ${cart.totalAmount.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFFF5DF4D), fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text('Developed by Novara', style: TextStyle(color: Colors.grey[400], fontSize: 11, letterSpacing: 0.5)),
      ),
    );
  }
}
