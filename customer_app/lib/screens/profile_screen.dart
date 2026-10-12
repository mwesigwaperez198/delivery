import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildProfileCard()),
          SliverToBoxAdapter(child: _buildMenuSection('My Account', [
            _MenuItem(Icons.location_on_rounded, 'Saved Addresses', const Color(0xFF0E9594), () {}),
            _MenuItem(Icons.favorite_rounded, 'Favourites', Colors.red, () {}),
            _MenuItem(Icons.history_rounded, 'Order History', Colors.orange, () {}),
          ], context)),
          SliverToBoxAdapter(child: _buildMenuSection('Earn with Dynamics', [
            _MenuItem(Icons.delivery_dining_rounded, 'Become a Rider', const Color(0xFF0E9594), () => _showBecomeRider(context)),
            _MenuItem(Icons.storefront_rounded, 'Register as Vendor', Colors.purple, () {}),
          ], context)),
          SliverToBoxAdapter(child: _buildMenuSection('Support', [
            _MenuItem(Icons.help_outline_rounded, 'Help & FAQ', Colors.blue, () {}),
            _MenuItem(Icons.chat_bubble_outline_rounded, 'Chat Support', const Color(0xFF0E9594), () {}),
            _MenuItem(Icons.star_outline_rounded, 'Rate the App', Colors.amber, () {}),
          ], context)),
          SliverToBoxAdapter(child: _buildMenuSection('Account', [
            _MenuItem(Icons.settings_rounded, 'Settings', Colors.grey, () {}),
            _MenuItem(Icons.logout_rounded, 'Log Out', Colors.red, () {}),
          ], context)),
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
      title: const Text('Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      pinned: true,
      actions: [
        IconButton(icon: const Icon(Icons.edit_rounded, color: Colors.white), onPressed: () {}),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F2D2E), Color(0xFF0E9594)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
              border: Border.all(color: const Color(0xFFF5DF4D), width: 2),
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 36),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('John Mukasa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                const Text('+256 77X XXX XXX', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5DF4D),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('7 deliveries • 3 to free!', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF151515))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(String title, List<_MenuItem> items, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black08, blurRadius: 6)],
            ),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                return Column(
                  children: [
                    ListTile(
                      leading: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: item.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item.icon, color: item.color, size: 20),
                      ),
                      title: Text(item.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                      onTap: item.onTap,
                    ),
                    if (i < items.length - 1) const Divider(height: 1, indent: 66),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showBecomeRider(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.delivery_dining_rounded, size: 56, color: Color(0xFF0E9594)),
            const SizedBox(height: 12),
            const Text('Become a Dynamics Rider', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text('Earn UGX 50,000–150,000/day delivering in your area.', style: TextStyle(color: Colors.grey[500], fontSize: 13), textAlign: TextAlign.center),
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
                child: const Text('Apply Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _MenuItem(this.icon, this.label, this.color, this.onTap);
}
