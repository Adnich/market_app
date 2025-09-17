import 'package:flutter_test/flutter_test.dart';
import 'package:market_app/src/app.dart';
import 'package:market_app/src/entry_points/flavor_config/dev_config.dart';

void main() {
  testWidgets('App builds (DEV)', (WidgetTester tester) async {
await tester.pumpWidget(App(flavor: DevConfig()));
    expect(find.textContaining('Market App'), findsOneWidget);
  });
}
