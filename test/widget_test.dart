import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lucid_dreams_aaa/main.dart';

void main() {
  testWidgets('Erster Start zeigt die Einführung', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(const LucidApp());
    // Echte Ein-/Ausgabe (Journal-Ordner) abwarten, dann den Auftakt mit Wortmarke.
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 500)));
    await tester.pump(const Duration(seconds: 3));
    // Der Sternenhimmel bewegt sich dauerhaft, deshalb feste Schritte statt pumpAndSettle.
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Wach werden, während du träumst.'), findsOneWidget);
    expect(find.text('Weiter'), findsOneWidget);
  });
}
