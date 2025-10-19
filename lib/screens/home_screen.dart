import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:market_app/src/dependencies.dart';
import 'package:market_app/src/app_router/app_routes.dart';
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
    final firestore = getIt<FirebaseFirestore>();
    final user = auth.currentUser;

    final bool isGuest =
        user == null || user.isAnonymous; // ✅ prepoznaje gosta

    return Scaffold(
      appBar: AppBar(
        title: Text('Dobrodošli, ${user?.email ?? 'posjetioče'}'),
        actions: [
          if (!isGuest) // 👈 prikazuje profil samo ako je prijavljen
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

      // 🔹 FAB se prikazuje SAMO ako je korisnik prijavljen
      floatingActionButton: isGuest
          ? null
          : FloatingActionButton(
              onPressed: () => _goToAddProduct(context),
              child: const Icon(Icons.add),
            ),

      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text('Greška pri učitavanju: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nema unesenih proizvoda.'));
          }

          final products = snapshot.data!.docs;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              try {
                final data = products[index].data() as Map<String, dynamic>;
                final name = data['name'] ?? 'Bez naziva';
                final price = (data['price'] is num)
                    ? (data['price'] as num).toDouble()
                    : 0.0;
                final description = data['description'] ?? '';
                final imageUrl = data['imageUrl'];

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: ListTile(
                    leading: imageUrl != null && imageUrl.toString().isNotEmpty
                        ? Image.network(
                            imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.image_not_supported),
                    title: Text(name),
                    subtitle: Text(
                      'Cijena: ${price.toStringAsFixed(2)} KM\nOpis: $description',
                    ),

                    // ✏️ ikonica za edit prikazuje se samo ako nije gost
                    trailing: isGuest
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              context.push(
                                AppRoutes.addOrEditProduct,
                                extra: {
                                  'productId': products[index].id,
                                  'existingData': data,
                                },
                              );
                            },
                          ),
                  ),
                );
              } catch (e, st) {
                debugPrint('⚠️ Greška pri prikazu proizvoda: $e');
                debugPrintStack(stackTrace: st);
                return const ListTile(
                  title: Text('Greška pri učitavanju proizvoda'),
                );
              }
            },
          );
        },
      ),
    );
  }
}
