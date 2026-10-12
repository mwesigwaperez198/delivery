class Merchant {
  final String id;
  final String businessName;
  final String description;
  final String category;
  final String logo;
  final String landmark;
  final double rating;
  final int reviewCount;
  final int averagePrepTime;

  Merchant({
    required this.id,
    required this.businessName,
    required this.description,
    required this.category,
    required this.logo,
    required this.landmark,
    required this.rating,
    required this.reviewCount,
    required this.averagePrepTime,
  });

  factory Merchant.fromJson(Map<String, dynamic> json) {
    return Merchant(
      id: json['_id'],
      businessName: json['businessName'],
      description: json['description'] ?? '',
      category: json['category'],
      logo: json['logo'] ?? '',
      landmark: json['location']?['landmark'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] ?? 0,
      averagePrepTime: json['preparationTimeAverage'] ?? 20,
    );
  }
}
