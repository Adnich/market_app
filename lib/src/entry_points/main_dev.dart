import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options_dev.dart' as dev;
import '../app.dart';
import '../flavor_config/flavor_config.dart';
import '../flavor_config/dev_config.dart';
import '../dependencies.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Inicijalizuj dependency injection (FirebaseModule, UtilityModule, itd.)
  await configureDependencies('dev');

  // 🔹 Zadrži postojeću inicijalizaciju Firebase-a ako je koristiš ručno
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: dev.DefaultFirebaseOptions.currentPlatform,
    );
  }

  const FlavorConfig flavor = DevConfig();
  runApp(App(flavor: flavor));
}
