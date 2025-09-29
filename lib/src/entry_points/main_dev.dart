import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options_prod.dart' as prod;

import '../app.dart';
import '../flavor_config/flavor_config.dart';
import '../flavor_config/prod_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: prod.DefaultFirebaseOptions.currentPlatform,
  );

  const FlavorConfig flavor = ProdConfig();
  runApp(App(flavor: flavor));
}
