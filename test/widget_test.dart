import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lucid_dreams_aaa/main.dart';

void main() {
  testWidgets('Erster Start zeigt die Einführung', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(const LucidApp());
    await tester.pumpAndSettle();

    expect(find.text('Wach werden, während du träumst.'), findsOneWidget);
    expect(find.text('Weiter'), findsOneWidget);
  });
}
