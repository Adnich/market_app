import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'dependencies.config.dart'; 

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies(String env) async {
  await getIt.init(environment: env);
}
