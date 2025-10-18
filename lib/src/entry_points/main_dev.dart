// lib/src/entry_points/main_dev.dart
import 'package:flutter/material.dart';
import '../app.dart';
import '../flavor_config/flavor_config.dart';
import '../flavor_config/prod_config.dart';
import '../dependencies.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Inicijalizacija svih dependency-ja, uključujući Firebase preko @preResolve
  await configureDependencies('prod');

  const FlavorConfig flavor = ProdConfig();

  runApp(App(flavor: flavor));
}
