import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Početna'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
          )
        ],
      ),
      body: Center(
        child: Text(
          user != null
              ? 'Dobrodošao, ${user.email}'
              : 'Korisnik nije prijavljen.',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
