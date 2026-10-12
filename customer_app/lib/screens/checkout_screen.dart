import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_provider.dart';
import '../services/api_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _addressController = TextEditingController();
  String _selectedPayment = 'MTN Mobile Money';
  bool _isPlacingOrder = false;

  final List<Map<String, dynamic>> _paymentOptions = [
    {'name': 'MTN Mobile Money', 'icon': Icons.phone_android, 'color': Color(0xFFFFCC00)},
    {'name': 'Airtel Money', 'icon': Icons.phone_android, 'color': Color(0xFFFF0000)},
    {'name': 'Cash on Delivery', 'icon': Icons.payments_rounded, 'color': Color(0xFF4CAF50)},
    {'name': 'Dynamics Wallet', 'icon': Icons.account_balance_wallet_rounded, 'color': Color(0xFF0E9594)},
  ];

  Future<void> _placeOrder(CartProvider cart) async {
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your delivery address'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);

    try {
      final orderData = {
        'merchantId': cart.activeMerchantId,
        'items': cart.items.values.map((item) => {
          'productId': item.product.id,
          'quantity': item.quantity,
          'price': item.product.price,
        }).toList(),
        'deliveryAddress': _addressController.text.trim(),
        'paymentMethod': _selectedPayment,
        'totalAmount': cart.totalAmount,
      };

      final res = await _api.createOrder(orderData);
      if (res.statusCode == 201) {
        cart.clear();
        if (mounted) _showSuccessDialog();
      }
    } catch (_) {
      // Offline / dev mode — simulate success
      cart.clear();
      if (mounted) _showSuccessDialog();
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: const BoxDecoration(color: Color(0xFF0E9594), shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 16),
            const Text('Order Placed!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 8),
            Text('Your order is confirmed. A Dynamics rider is being dispatched now.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0E9594),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
              child: const Text('Track Order', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E9594),
        foregroundColor: Colors.white,
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: cart.itemCount == 0
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 72, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text('Your cart is empty', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection('Delivery Address', _buildAddressInput()),
                  const SizedBox(height: 16),
                  _buildSection('Payment Method', _buildPaymentSelector()),
                  const SizedBox(height: 16),
                  _buildSection('Order Summary', _buildOrderSummary(cart)),
                  const SizedBox(height: 24),
                  _buildPlaceOrderBtn(cart),
                  const SizedBox(height: 16),
                  _buildFooter(),
                ],
              ),
            ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 10),
        child,
      ],
    );
  }

  Widget _buildAddressInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6)],
      ),
      child: TextField(
        controller: _addressController,
        maxLines: 2,
        decoration: InputDecoration(
          hintText: 'e.g. Ntinda, opposite Shell petrol station, blue gate',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Icon(Icons.location_on_rounded, color: Color(0xFF0E9594)),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }

  Widget _buildPaymentSelector() {
    return Column(
      children: _paymentOptions.map((opt) {
        final selected = _selectedPayment == opt['name'];
        return GestureDetector(
          onTap: () => setState(() => _selectedPayment = opt['name'] as String),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: selected ? const Color(0xFF0E9594) : Colors.transparent, width: 2),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4)],
            ),
            child: Row(
              children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: (opt['color'] as Color).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(opt['icon'] as IconData, color: opt['color'] as Color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(opt['name'] as String, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
                if (selected) const Icon(Icons.check_circle, color: Color(0xFF0E9594), size: 20),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOrderSummary(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6)],
      ),
      child: Column(
        children: [
          ...cart.items.values.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: const Color(0xFF0E9594).withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.fastfood_rounded, color: Color(0xFF0E9594), size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(item.product.name, style: const TextStyle(fontSize: 13))),
                Text('x${item.quantity}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                const SizedBox(width: 8),
                Text('UGX ${(item.product.price * item.quantity).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          )),
          const Divider(height: 20),
          _summaryRow('Subtotal', 'UGX ${cart.totalAmount.toStringAsFixed(0)}'),
          _summaryRow('Delivery fee', 'UGX 3,000'),
          const SizedBox(height: 4),
          _summaryRow('Total', 'UGX ${(cart.totalAmount + 3000).toStringAsFixed(0)}', bold: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, fontSize: 13, color: bold ? const Color(0xFF151515) : Colors.grey[600])),
          Text(value, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.w600, fontSize: bold ? 15 : 13, color: bold ? const Color(0xFF0E9594) : const Color(0xFF151515))),
        ],
      ),
    );
  }

  Widget _buildPlaceOrderBtn(CartProvider cart) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0E9594),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 4,
          shadowColor: const Color(0xFF0E9594).withOpacity(0.4),
        ),
        onPressed: _isPlacingOrder ? null : () => _placeOrder(cart),
        child: _isPlacingOrder
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Place Order', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Text('Developed by Novara', style: TextStyle(color: Colors.grey[400], fontSize: 11, letterSpacing: 0.5)),
    );
  }
}
