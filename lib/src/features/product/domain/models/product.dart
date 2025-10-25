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
    this.available = true,
    required this.createdAt,
  });

  factory Product.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception("Firestore dokument ne sadrži podatke za proizvod.");
    }

    return ProductMapper.fromMap({
      ...data,
      'id': doc.id,
      'createdAt': data['createdAt'] is Timestamp
          ? data['createdAt']
          : Timestamp.now(),
    });
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
