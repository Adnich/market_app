// lib/src/entry_points/main_prod.dart
import 'package:flutter/material.dart';
import '../app.dart';
import '../flavor_config/flavor_config.dart';
import '../flavor_config/dev_config.dart';
import '../dependencies.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Inicijalizacija svih dependency-ja (uključujući Firebase preko @preResolve)
  await configureDependencies('dev');

  const FlavorConfig flavor = DevConfig();

  runApp(App(flavor: flavor));
}
