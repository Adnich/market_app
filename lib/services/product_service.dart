import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔹 Dohvata sve proizvode iz Firestore kolekcije
  Future<List<Product>> getProducts() async {
    final snapshot = await _firestore.collection('products').get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Product.fromFirestore(data, doc.id);
    }).toList();
  }
}
