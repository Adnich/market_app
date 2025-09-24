import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthStateNotifier extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;

  AuthStateNotifier() {
    _auth.authStateChanges().listen((User? u) {
      user = u;
      notifyListeners(); 
    });
  }

  bool get isLoggedIn => user != null;
}
