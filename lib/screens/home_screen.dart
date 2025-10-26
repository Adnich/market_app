import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:market_app/src/injection.dart';
import 'package:market_app/src/app_router/app_routes.dart';
import 'package:market_app/src/features/product/presentation/widgets/products_paged_list.dart';

class HomeScreen extends HookWidget {
  const HomeScreen({super.key});

  void _signOut(BuildContext context) async {
    final auth = getIt<FirebaseAuth>();
    await auth.signOut();
    if (context.mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final auth = getIt<FirebaseAuth>();
    final user = auth.currentUser;
    final bool isGuest = user == null || user.isAnonymous;

    final refreshCallback = useState<VoidCallback?>(null);

    return Scaffold(
      appBar: AppBar(
        title: Text('Dobrodošli, ${user?.email ?? 'posjetioče'}'),
        actions: [
          if (!isGuest)
            IconButton(
              icon: const Icon(Icons.person),
              tooltip: 'Moj profil',
              onPressed: () => context.push(AppRoutes.profile),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: isGuest ? 'Nazad na prijavu' : 'Odjava',
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      floatingActionButton: isGuest
          ? null
          : FloatingActionButton(
              onPressed: () async {
                await context.push(AppRoutes.addProduct);
                refreshCallback.value?.call(); 
              },
              child: const Icon(Icons.add),
            ),
      body: ProductsPagedList(
        isGuest: isGuest,
        onRefreshCallback: (refresh) {
          refreshCallback.value = refresh;
        },
      ),
    );
  }
}
