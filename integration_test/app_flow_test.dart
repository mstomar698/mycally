import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mycally/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app launches and shows splash content', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 4));

    expect(find.textContaining('MyCally'), findsWidgets);
  });
}
