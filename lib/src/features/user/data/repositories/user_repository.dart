import 'package:injectable/injectable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:market_app/src/features/user/domain/models/app_user.dart';

@singleton
class UserRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  // 🔹 Observable korisnik (možeš ga pratiti u UI-u pomoću ValueListenable)
  final ValueNotifier<AppUser?> currentUser = ValueNotifier(null);

  UserRepository(this._auth, this._firestore) {
    _init();
  }

  FirebaseFirestore get firestore => _firestore;
  bool get isLoggedIn => _auth.currentUser != null;
  String? get uid => _auth.currentUser?.uid;

  /// 🔹 Inicijalno učitavanje korisnika
  Future<void> _init() async {
    if (_auth.currentUser != null) {
      await loadUser();
    }
  }

  /// 🔹 Dohvata dokument korisnika
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDoc() async {
    final userId = uid;
    if (userId == null) throw Exception('Nema aktivnog korisnika.');
    return _firestore.collection('users').doc(userId).get();
  }

  /// 🔹 Učitava korisnika iz Firestore i sprema u `currentUser`
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

  /// 🔹 Osvježava korisnika
  Future<void> refreshUser() async {
    await loadUser();
  }

  /// 🔹 Ručno postavljanje korisnika (npr. nakon registracije)
  void setUser(AppUser user) {
    currentUser.value = user;
  }

  /// 🔹 Odjava i čišćenje state-a
  Future<void> signOut() async {
    await _auth.signOut();
    currentUser.value = null;
  }
}
