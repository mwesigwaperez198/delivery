import 'package:flutter/material.dart';
import 'merchant_category_view.dart';

class GroceriesView extends StatelessWidget {
  const GroceriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return const MerchantCategoryView(category: 'Supermarkets');
  }
}
