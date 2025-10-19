import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../../product/domain/models/product.dart';

@singleton
class ProductRepository {
  final FirebaseFirestore _firestore;

  ProductRepository(this._firestore);

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

class PageResult<T> {
  final List<T> items;
  final DocumentSnapshot? lastDoc;
  PageResult({required this.items, required this.lastDoc});
}

extension ProductPaging on ProductRepository {
  Future<PageResult<Product>> getFirstPage({int limit = 10}) async {
    final query = _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    final snap = await query.get();
    final items = snap.docs.map((d) => Product.fromFirestore(d)).toList();
    final last = snap.docs.isNotEmpty ? snap.docs.last : null;
    return PageResult(items: items, lastDoc: last);
  }

  Future<PageResult<Product>> getNextPage({
    required DocumentSnapshot lastDoc,
    int limit = 10,
  }) async {
    final query = _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .startAfterDocument(lastDoc)
        .limit(limit);

    final snap = await query.get();
    final items = snap.docs.map((d) => Product.fromFirestore(d)).toList();
    final last = snap.docs.isNotEmpty ? snap.docs.last : null;
    return PageResult(items: items, lastDoc: last);
  }
}
