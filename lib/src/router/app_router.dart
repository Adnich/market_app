import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:market_app/src/injection.dart';
import '/screens/login_screen.dart';
import '/screens/register_screen.dart';
import '/screens/home_screen.dart';
import '/screens/add_product_screen.dart';
import '/screens/profile_screen.dart';
import '/screens/edit_profile_screen.dart';
import '/src/router/auth_refresh_stream.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final auth = getIt<FirebaseAuth>();
    final user = auth.currentUser;
    final loggingInOrRegistering =
        state.matchedLocation == '/login' || state.matchedLocation == '/register';
    final visitingPublicHome = state.matchedLocation == '/home';

    if (user == null && !loggingInOrRegistering && !visitingPublicHome) {
      return '/login';
    }

    if (user != null && loggingInOrRegistering) {
      return '/home';
    }

    return null;
  },
  refreshListenable: AuthRefreshStream(
  stream: getIt<FirebaseAuth>().authStateChanges(),
  ),
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/add-product',
      builder: (context, state) => const AddOrEditProductScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/add-or-edit-product',
      builder: (context, state) {
      final extras = state.extra as Map<String, dynamic>?;
      return AddOrEditProductScreen(
      productId: extras?['productId'],
      existingProduct: extras?['existingProduct'], 
    );
  },
),


  ],
);
