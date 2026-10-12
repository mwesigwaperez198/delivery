import 'package:flutter/material.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int _deliveryCount = 7; // out of 10 for free delivery

  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': 'MTN Mobile Money', 'number': '077X XXX XXX', 'icon': Icons.phone_android, 'color': Color(0xFFFFCC00), 'active': true},
    {'name': 'Airtel Money', 'number': '075X XXX XXX', 'icon': Icons.phone_android, 'color': Color(0xFFFF0000), 'active': false},
    {'name': 'Visa Card', 'number': '**** **** **** 4242', 'icon': Icons.credit_card, 'color': Color(0xFF1A1F71), 'active': false},
    {'name': 'Cash on Delivery', 'number': 'Pay when delivered', 'icon': Icons.payments_rounded, 'color': Color(0xFF4CAF50), 'active': false},
  ];

  final List<Map<String, dynamic>> _transactions = [
    {'desc': 'Chicken Palace', 'amount': '-UGX 25,000', 'date': 'Today', 'type': 'debit'},
    {'desc': 'Loyalty Bonus', 'amount': '+UGX 5,000', 'date': 'Yesterday', 'type': 'credit'},
    {'desc': 'City Pharmacy', 'amount': '-UGX 8,500', 'date': 'Mon', 'type': 'debit'},
    {'desc': 'Wallet Top-up', 'amount': '+UGX 50,000', 'date': 'Sun', 'type': 'credit'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildBalanceCard()),
          SliverToBoxAdapter(child: _buildLoyalty()),
          SliverToBoxAdapter(child: _buildPaymentMethods()),
          SliverToBoxAdapter(child: _buildTransactions()),
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text('Developed by Novara', style: TextStyle(color: Colors.grey, fontSize: 11, letterSpacing: 0.5))),
          )),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: const Color(0xFF0E9594),
      title: const Text('Wallet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      pinned: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.add_circle_outline, color: Colors.white),
          onPressed: _showTopUp,
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F2D2E), Color(0xFF0E9594)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF0E9594).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dynamics Wallet', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          const Text('UGX 42,500', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            children: [
              _walletAction(Icons.add_rounded, 'Top Up', () => _showTopUp()),
              const SizedBox(width: 12),
              _walletAction(Icons.send_rounded, 'Send', () {}),
              const SizedBox(width: 12),
              _walletAction(Icons.history_rounded, 'History', () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _walletAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFF5DF4D), size: 16),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildLoyalty() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black08, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFF5DF4D), size: 22),
              const SizedBox(width: 8),
              const Text('Loyalty Rewards', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const Spacer(),
              Text('$_deliveryCount/10', style: const TextStyle(color: Color(0xFF0E9594), fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _deliveryCount / 10,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0E9594)),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${10 - _deliveryCount} more deliveries for 1 FREE delivery!',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment Methods', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          ..._paymentMethods.asMap().entries.map((entry) {
            final i = entry.key;
            final method = entry.value;
            return GestureDetector(
              onTap: () => setState(() {
                for (var m in _paymentMethods) m['active'] = false;
                _paymentMethods[i]['active'] = true;
              }),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: method['active'] ? const Color(0xFF0E9594) : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: [BoxShadow(color: Colors.black08, blurRadius: 6)],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: (method['color'] as Color).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(method['icon'] as IconData, color: method['color'] as Color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(method['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          Text(method['number'] as String, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                        ],
                      ),
                    ),
                    if (method['active'] as bool)
                      const Icon(Icons.check_circle, color: Color(0xFF0E9594), size: 22),
                  ],
                ),
              ),
            );
          }),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, color: Color(0xFF0E9594)),
            label: const Text('Add Payment Method', style: TextStyle(color: Color(0xFF0E9594))),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Transactions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          ..._transactions.map((t) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black08, blurRadius: 4)],
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: t['type'] == 'credit' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    t['type'] == 'credit' ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                    color: t['type'] == 'credit' ? Colors.green : Colors.red,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(t['desc'] as String, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      t['amount'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: t['type'] == 'credit' ? Colors.green : const Color(0xFF151515),
                      ),
                    ),
                    Text(t['date'] as String, style: TextStyle(color: Colors.grey[400], fontSize: 10)),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  void _showTopUp() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Top Up Wallet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              children: ['5,000', '10,000', '20,000', '50,000'].map((amt) => GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF0E9594)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('UGX $amt', style: const TextStyle(color: Color(0xFF0E9594), fontWeight: FontWeight.w600)),
                ),
              )).toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0E9594),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Confirm Top Up', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
