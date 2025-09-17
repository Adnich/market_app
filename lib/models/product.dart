class Product {
  final String id;
  final String name;
  final double price;
  final bool available;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.available,
  });

  factory Product.fromMap(Map<String, dynamic> data, String documentId) {
    return Product(
      id: documentId,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      available: data['available'] ?? false,
    );
  }
}
