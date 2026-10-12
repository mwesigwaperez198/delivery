import 'package:flutter/material.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock active order state: 0=Preparing, 1=Rider on way, 2=Delivered
  int _orderState = 1;

  final List<Map<String, dynamic>> _pastOrders = [
    {'id': '#DYN-4421', 'vendor': 'Chicken Palace', 'items': 'Chicken & Chips x1', 'total': 'UGX 25,000', 'date': 'Today, 11:30am', 'status': 'Delivered'},
    {'id': '#DYN-4398', 'vendor': 'City Pharmacy', 'items': 'Panadol x2, Strepsils x1', 'total': 'UGX 8,500', 'date': 'Yesterday', 'status': 'Delivered'},
    {'id': '#DYN-4301', 'vendor': 'Uchumi Express', 'items': 'Milk, Bread, Eggs', 'total': 'UGX 18,000', 'date': 'Mon, 9:15am', 'status': 'Delivered'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E9594),
        title: const Text('My Orders', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFF5DF4D),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [Tab(text: 'Active'), Tab(text: 'History')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildActiveOrder(), _buildHistory()],
      ),
    );
  }

  Widget _buildActiveOrder() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTrackingSteps(),
          const SizedBox(height: 16),
          _buildMapPlaceholder(),
          const SizedBox(height: 16),
          _buildRiderCard(),
          const SizedBox(height: 16),
          _buildOrderSummaryCard(),
        ],
      ),
    );
  }

  Widget _buildTrackingSteps() {
    final steps = ['Preparing', 'Rider on way', 'Delivered'];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black08, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order #DYN-4422', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text('Chicken Palace • Est. 12 mins', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          const SizedBox(height: 16),
          Row(
            children: List.generate(steps.length, (i) {
              final isActive = i <= _orderState;
              final isCurrent = i == _orderState;
              return Expanded(
                child: Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive ? const Color(0xFF0E9594) : Colors.grey[200],
                            border: isCurrent ? Border.all(color: const Color(0xFFF5DF4D), width: 3) : null,
                          ),
                          child: Icon(
                            i == 0 ? Icons.restaurant : i == 1 ? Icons.delivery_dining : Icons.check_circle,
                            color: isActive ? Colors.white : Colors.grey,
                            size: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(steps[i], style: TextStyle(fontSize: 9, color: isActive ? const Color(0xFF0E9594) : Colors.grey, fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal)),
                      ],
                    ),
                    if (i < steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          margin: const EdgeInsets.only(bottom: 20),
                          color: i < _orderState ? const Color(0xFF0E9594) : Colors.grey[200],
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF0E9594).withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0E9594).withOpacity(0.2)),
      ),
      child: Stack(
        children: [
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map_rounded, size: 48, color: Color(0xFF0E9594)),
                SizedBox(height: 8),
                Text('Live Map Tracking', style: TextStyle(color: Color(0xFF0E9594), fontWeight: FontWeight.bold)),
                Text('Rider is 1.2km away', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0E9594),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.circle, color: Color(0xFFF5DF4D), size: 8),
                  SizedBox(width: 4),
                  Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black08, blurRadius: 8)],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 26,
            backgroundColor: Color(0xFF0E9594),
            child: Icon(Icons.person, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Musa Kato', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const Text(' 4.9', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 8),
                    const Icon(Icons.delivery_dining, size: 14, color: Colors.grey),
                    Text(' Boda • UBE 234K', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              _riderActionBtn(Icons.chat_bubble_outline_rounded, const Color(0xFF0E9594), () => _showChat()),
              const SizedBox(width: 8),
              _riderActionBtn(Icons.call_rounded, Colors.green, () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _riderActionBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  void _showChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: const Row(
                children: [
                  CircleAvatar(backgroundColor: Color(0xFF0E9594), child: Icon(Icons.person, color: Colors.white)),
                  SizedBox(width: 12),
                  Text('Musa Kato', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _chatBubble('I am 5 minutes away', false),
                  _chatBubble('Okay, I am at the gate', true),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(24)),
                      child: const TextField(decoration: InputDecoration(hintText: 'Message rider...', border: InputBorder.none)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 40, height: 40,
                    decoration: const BoxDecoration(color: Color(0xFF0E9594), shape: BoxShape.circle),
                    child: const Icon(Icons.send, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chatBubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF0E9594) : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(text, style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 13)),
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black08, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          _summaryRow('Chicken & Chips x1', 'UGX 22,000'),
          _summaryRow('Delivery fee', 'UGX 3,000'),
          const Divider(),
          _summaryRow('Total', 'UGX 25,000', bold: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
          Text(value, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, fontSize: 13, color: bold ? const Color(0xFF0E9594) : null)),
        ],
      ),
    );
  }

  Widget _buildHistory() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pastOrders.length,
      itemBuilder: (context, i) {
        final order = _pastOrders[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black08, blurRadius: 6)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(order['id']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(order['status']!, style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(order['vendor']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Text(order['items']!, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(order['date']!, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                  Text(order['total']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0E9594))),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF0E9594)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onPressed: () {},
                  child: const Text('Order Again', style: TextStyle(color: Color(0xFF0E9594), fontSize: 13)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
