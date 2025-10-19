import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductRepository {
  final FirebaseFirestore _firestore;

  ProductRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<String> addProduct(Product product) async {
    final docRef = _firestore.collection('products').doc(); 

    await docRef.set({
      ...product.toFirestore(),
      'id': docRef.id,          
    });

    return docRef.id;
  }

  Future<void> updateProduct(String id, Product product) async {
    await _firestore.collection('products').doc(id).update(product.toFirestore());
  }

  Future<void> deleteProduct(String id) async {
    await _firestore.collection('products').doc(id).delete();
  }

  Future<List<Product>> getProductsOnce() async {
    final snapshot = await _firestore.collection('products').get();
    return snapshot.docs.map((doc) {
      return Product.fromFirestore(doc); 
    }).toList();
  }

  Stream<List<Product>> getProductsStream() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromFirestore(doc); 
      }).toList();
    });
  }
}
