import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/cart_provider.dart';
import '../services/api_service.dart';
import '../widgets/location_picker_widget.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final ApiService _apiService = ApiService();
  LatLng? _selectedLocation;
  String _addressLandmark = '';
  bool _isPlacingOrder = false;

  void _onLocationSelected(LatLng position, String address) {
    setState(() {
      _selectedLocation = position;
      _addressLandmark = address;
    });
  }

  Future<void> _placeOrder() async {
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a delivery location on the map')),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);
    final cart = Provider.of<CartProvider>(context, listen: false);

    try {
      final orderData = {
        'merchantId': cart.activeMerchantId,
        'items': cart.items.values.map((item) => {
          'productId': item.product.id,
          'quantity': item.quantity,
          'price': item.product.price,
        }).toList(),
        'deliveryLocation': {
          'type': 'Point',
          'coordinates': [_selectedLocation!.longitude, _selectedLocation!.latitude],
          'landmark': _addressLandmark,
        },
        'totalAmount': cart.totalAmount,
      };

      final response = await _apiService.createOrder(orderData);
      if (response.statusCode == 201) {
        cart.clear();
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Dynamics Dispatch'),
              content: const Text('Your order has been placed! Our AI is JIT dispatching a carrier now.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to place order. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamics Checkout'),
      ),
      body: cart.itemCount == 0
          ? const Center(child: Text('Your cart is empty'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '1. Delivery Address (Pin Picker)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  LocationPickerWidget(onLocationSelected: _onLocationSelected),
                  const SizedBox(height: 24),
                  const Text(
                    '2. Order Summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items.values.toList()[index];
                      return ListTile(
                        title: Text(item.product.name),
                        trailing: Text('x${item.quantity}  UGX ${item.product.price * item.quantity}'),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Text(
                      'UGX ${cart.totalAmount}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isPlacingOrder ? null : _placeOrder,
                      child: _isPlacingOrder
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Confirm Order'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
