import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'src/router/app_router.dart';
import 'src/dependencies.dart'; // 👈 dodano

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Inicijalizacija dependency injection sistema
  await configureDependencies('dev');

  runApp(const AppEntry());
}

class AppEntry extends StatelessWidget {
  const AppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Firebase inicijalizacija može ostati jer FutureBuilder koristi snapshot logiku
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
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
              body: Center(
                child: Text('Greška pri inicijalizaciji Firebase-a: ${snapshot.error}'),
              ),
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
