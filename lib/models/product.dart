import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'product.mapper.dart';

@MappableClass()
class Product with ProductMappable {
  final String id;
  final String name;
  final double price;
  final String description;
  final String? imageUrl;
  final bool available;
  final Timestamp createdAt;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    this.imageUrl,
    required this.available,
    required this.createdAt,
  });

  factory Product.fromFirestore(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'],
      available: data['available'] ?? true,
      createdAt: data['createdAt'] is Timestamp
          ? data['createdAt'] as Timestamp
          : Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'available': available,
      'createdAt': createdAt,
    };
  }
}
