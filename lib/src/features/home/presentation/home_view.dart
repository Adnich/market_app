import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:market_app/src/dependencies.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = getIt<FirebaseAuth>();
    final user = auth.currentUser;
    final label = user == null
        ? 'Gost (nije prijavljen)'
        : (user.isAnonymous ? 'Gost (anonimni)' : 'Prijavljen: ${user.email ?? user.uid}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final auth = getIt<FirebaseAuth>();
              await auth.signOut();
            },
          )
        ],
      ),
      body: Center(child: Text(label)),
    );
  }
}
