import 'package:flutter/material.dart';
import 'merchant_category_view.dart';

class DynamicHubDashboard extends StatelessWidget {
  const DynamicHubDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Dynamics Slogan / Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF0E9594),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dynamics Deliveries',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              Text(
                'Anything, Anywhere in Uganda.',
                style: TextStyle(
                  color: Color(0xFFF5DF4D),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        
        // Category Selector
        Expanded(
          child: DefaultTabController(
            length: 4,
            child: Column(
              children: [
                const TabBar(
                  labelColor: Color(0xFF0E9594),
                  indicatorColor: Color(0xFF0E9594),
                  isScrollable: true,
                  tabs: [
                    Tab(text: 'Food & Restaurants', icon: Icon(Icons.restaurant)),
                    Tab(text: 'Supermarkets', icon: Icon(Icons.shopping_cart)),
                    Tab(text: 'Electricals & More', icon: Icon(Icons.bolt)),
                    Tab(text: 'Package Delivery', icon: Icon(Icons.local_shipping)),
                  ],
                ),
                const Expanded(
                  child: TabBarView(
                    children: [
                      MerchantCategoryView(category: 'Food & Restaurants'),
                      MerchantCategoryView(category: 'Supermarkets'),
                      MerchantCategoryView(category: 'Electricals'),
                      MerchantCategoryView(category: 'Packages'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
