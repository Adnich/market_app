import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:market_app/src/dependencies.dart';
import 'package:market_app/src/app_router/app_routes.dart'; // ✅ Dodano za centralizovane rute
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Dobrodošli, ${user?.email ?? 'korisniče'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Moj profil',
            onPressed: () {
              context.push(AppRoutes.profile); 
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Odjava',
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _goToAddProduct(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('products').snapshots(), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nema unesenih proizvoda.'));
          }

          final products = snapshot.data!.docs;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final data = products[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['name'] ?? 'Bez naziva'),
                subtitle: Text('Cijena: ${data['price'] ?? 'N/A'} KM'),
                trailing: IconButton(
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
              );
            },
          );
        },
      ),
    );
  }
}
