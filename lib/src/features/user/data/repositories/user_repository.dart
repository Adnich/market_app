import 'package:injectable/injectable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



@singleton
class UserRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  User? currentUser;
  Map<String, dynamic>? userProfile; 

  UserRepository(this._auth, this._firestore) {
    _init();
  }

  Future<void> _init() async {
    currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _loadUserProfile();
    }
  }

  Future<void> _loadUserProfile() async {
    final uid = currentUser?.uid;
    if (uid == null) return;

    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      userProfile = doc.data();
    }
  }

  bool get isLoggedIn => currentUser != null;
  String? get uid => currentUser?.uid;

  Future<void> signOut() async {
    await _auth.signOut();
    currentUser = null;
    userProfile = null;
  }

  Future<void> refreshUser() async {
    currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _loadUserProfile();
    }
  }
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDoc() {
  return _firestore.collection('users').doc(uid).get();
}
  FirebaseFirestore get firestore => _firestore;

}
