import 'package:injectable/injectable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:market_app/src/features/user/domain/models/app_user.dart';

@singleton
class UserRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  final ValueNotifier<AppUser?> currentUser = ValueNotifier(null);

  UserRepository(this._auth, this._firestore) {
    _init();
  }

  FirebaseFirestore get firestore => _firestore;
  bool get isLoggedIn => _auth.currentUser != null;
  String? get uid => _auth.currentUser?.uid;

  Future<void> _init() async {
    if (_auth.currentUser != null) {
      await loadUser();
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDoc() async {
    final userId = uid;
    if (userId == null) throw Exception('Nema aktivnog korisnika.');
    return _firestore.collection('users').doc(userId).get();
  }

  Future<void> loadUser() async {
    final userId = uid;
    if (userId == null) {
      currentUser.value = null;
      return;
    }

    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists && doc.data() != null) {
      currentUser.value = AppUser.fromFirestore(doc);
    } else {
      currentUser.value = null;
    }
  }

  Future<void> refreshUser() async {
    await loadUser();
  }

  void setUser(AppUser user) {
    currentUser.value = user;
  }

  Future<void> updateUser(Map<String, dynamic> data) async {
    final userId = uid;
    if (userId == null) throw Exception('Nema aktivnog korisnika.');

    await _firestore.collection('users').doc(userId).update(data);
    await loadUser();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    currentUser.value = null;
  }
}
