import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthRefreshStream extends ChangeNotifier {
  late final StreamSubscription<User?> _subscription;

  AuthRefreshStream({required Stream<User?> stream}) {
    _subscription = stream.listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
