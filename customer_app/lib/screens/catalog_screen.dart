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
  final ApiService _apiService = ApiService();
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCatalog();
  }

  Future<void> _fetchCatalog() async {
    try {
      final response = await _apiService.getMerchantCatalog(widget.merchant.id);
      if (response.statusCode == 200) {
        final List<dynamic> productsJson = response.data['products'];
        setState(() {
          _products = productsJson.map((json) => Product.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load catalog')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.merchant.businessName),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                ),
              ),
              if (cart.itemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${cart.itemCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                final quantity = cart.getProductQuantity(product.id);

                return ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image),
                  ),
                  title: Text(product.name),
                  subtitle: Text('UGX ${product.price.toStringAsFixed(0)}'),
                  trailing: quantity == 0
                      ? ElevatedButton(
                          onPressed: () => cart.addItem(product, widget.merchant.id),
                          child: const Text('Add'),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => cart.removeItem(product.id),
                            ),
                            Text('$quantity'),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => cart.addItem(product, widget.merchant.id),
                            ),
                          ],
                        ),
                );
              },
            ),
    );
  }
}
