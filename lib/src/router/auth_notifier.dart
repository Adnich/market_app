import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:market_app/src/dependencies.dart';

class AuthStateNotifier extends ChangeNotifier {
  final FirebaseAuth _auth = getIt<FirebaseAuth>(); 
  User? user;

  AuthStateNotifier() {
    _auth.authStateChanges().listen((User? u) {
      user = u;
      notifyListeners(); 
    });
  }

  bool get isLoggedIn => user != null;
}
