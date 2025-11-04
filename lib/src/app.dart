import 'package:flutter/material.dart';
import 'flavor_config/flavor_config.dart';
import 'app_router/app_pages.dart';

class App extends StatelessWidget {
  final FlavorConfig flavor;
  const App({super.key, required this.flavor});

  @override
  Widget build(BuildContext context) {
    final router = buildRouter();
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: flavor.appName,
      routerConfig: router,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
    );
  }
}
