import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:market_app/src/dependencies.dart';
import 'package:market_app/src/app_router/app_routes.dart';
import 'package:market_app/models/product.dart';
import 'package:market_app/repositories/product_repository.dart';
import '/screens/add_product_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _signOut(BuildContext context) async {
    final auth = getIt<FirebaseAuth>();
    await auth.signOut();
    context.go(AppRoutes.login);
  }

  void _goToAddProduct(BuildContext context) {
    context.push(AppRoutes.addProduct);
  }

  @override
  Widget build(BuildContext context) {
    final auth = getIt<FirebaseAuth>();
    final user = auth.currentUser;
    final bool isGuest =
        user == null || user.isAnonymous; 

    final repository = ProductRepository(); 

    return Scaffold(
      appBar: AppBar(
        title: Text('Dobrodošli, ${user?.email ?? 'posjetioče'}'),
        actions: [
          if (!isGuest)
            IconButton(
              icon: const Icon(Icons.person),
              tooltip: 'Moj profil',
              onPressed: () {
                context.push(AppRoutes.profile);
              },
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
              onPressed: () => _goToAddProduct(context),
              child: const Icon(Icons.add),
            ),

      body: StreamBuilder<List<Product>>(
        stream: repository.getProductsStream(), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text('Greška pri učitavanju: ${snapshot.error}'));
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return const Center(child: Text('Nema unesenih proizvoda.'));
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  leading: product.imageUrl != null &&
                          product.imageUrl!.isNotEmpty
                      ? Image.network(
                          product.imageUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image_not_supported),
                  title: Text(product.name),
                  subtitle: Text(
                    'Cijena: ${product.price.toStringAsFixed(2)} KM\nOpis: ${product.description}',
                  ),

                  trailing: isGuest
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            context.push(
                              AppRoutes.addOrEditProduct,
                              extra: {
                                'productId': product.id,
                                'existingData': product.toFirestore(),
                              },
                            );
                          },
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
