// lib/src/dependencies.dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'dependencies.config.dart';

/// Globalni servis locator instance
final GetIt getIt = GetIt.instance;

/// Inicijalizacija svih dependency-ja (uključujući Firebase)
///
/// Parametar [env] definira okruženje ("dev", "prod", itd.).
/// Ako koristiš @preResolve u modulima (npr. FirebaseModule),
/// svi async servisi će se inicijalizovati prije nego što
/// getIt postane spreman za korištenje.
@InjectableInit()
Future<void> configureDependencies(String env) async {
  await getIt.init(environment: env);
}
