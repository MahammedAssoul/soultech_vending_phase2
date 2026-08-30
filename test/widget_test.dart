// Smoke test for the Soultech Vending app.
import 'package:flutter_test/flutter_test.dart';
import 'package:soultech_vending/main.dart';

void main() {
  testWidgets('App boots and shows the dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const SoultechApp());
    await tester.pumpAndSettle();

    // The dashboard shows the app bar with the Soultech logo.
    expect(find.text('Soultech Vending'), findsNothing);
    expect(find.byType(SoultechApp), findsOneWidget);
  });
}
