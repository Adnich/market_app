import 'package:cloud_firestore/cloud_firestore.dart';
import '../src/features/product/domain/models/product.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Product>> getProducts() async {
    final snapshot = await _firestore.collection('products').get();

    return snapshot.docs.map((doc) {
      return Product.fromFirestore(doc); 
    }).toList();
  }
}
