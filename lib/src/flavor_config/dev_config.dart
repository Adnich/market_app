import 'flavor_config.dart';

class DevConfig implements FlavorConfig {
  const DevConfig();                       
  @override String get appName => 'Market App (DEV)';
  @override bool get isProd => false;
}
