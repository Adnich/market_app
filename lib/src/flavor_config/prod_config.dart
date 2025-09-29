import 'flavor_config.dart';

class ProdConfig implements FlavorConfig {
  const ProdConfig();             
  @override String get appName => 'Market App';
  @override bool get isProd => true;
}
