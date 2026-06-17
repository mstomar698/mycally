import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mycally/src/app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  bool splashContentVisible(WidgetTester tester) {
    return find.textContaining('MyCally').evaluate().isNotEmpty ||
        find.textContaining('माईकैली').evaluate().isNotEmpty ||
        find.text('Get Started').evaluate().isNotEmpty ||
        find.text('शुरू करें').evaluate().isNotEmpty ||
        find.byIcon(Icons.calendar_month).evaluate().isNotEmpty;
  }

  testWidgets('app launches and shows splash content', (tester) async {
    await app.main();
    await tester.pump();

    const step = Duration(milliseconds: 500);
    const maxWait = Duration(seconds: 45);
    var waited = Duration.zero;

    while (waited < maxWait && !splashContentVisible(tester)) {
      await tester.pump(step);
      waited += step;
    }

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(splashContentVisible(tester), isTrue);
  });
}
