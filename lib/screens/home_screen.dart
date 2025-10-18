import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart'; 
import '/screens/add_product_screen.dart'; 

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    context.go('/login'); 
  }

  void _goToAddProduct(BuildContext context) {
    context.push('/add-product'); 
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Dobrodošli, ${user?.email ?? 'korisniče'}'),
        actions: [
  IconButton(
    icon: const Icon(Icons.person),
    tooltip: 'Moj profil',
    onPressed: () {
      context.push('/profile');
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
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
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
          '/add-or-edit-product',
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
