import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'app_routes.dart';
import '../features/home/presentation/home_view.dart';
import '../features/auth/presentation/login_view.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription _sub;
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) {
          final user = FirebaseAuth.instance.currentUser;
          return user == null ? const LoginView() : const HomeView();
        },
      ),
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginView()),
    ],
  );
}
