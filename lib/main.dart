import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 
import 'src/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppEntry());
}

class AppEntry extends StatelessWidget {
  const AppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform, // 👈 OVDJE DODAJ
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routerConfig: appRouter,
            title: 'Market App',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
            ),
          );
        }

        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Greška pri inicijalizaciji Firebase-a')),
            ),
          );
        }

        return const MaterialApp(
          home: Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }
}
