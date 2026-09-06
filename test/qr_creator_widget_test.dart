import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soultech_vending/features/qr_creator/qr_creator_page.dart';
import 'package:soultech_vending/features/qr_creator/qr_data_type.dart';

void main() {
  testWidgets('QR Creator page renders and generates a QR (Web URL)',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: QrCreatorPage()),
    );
    await tester.pumpAndSettle();

    // Default type is Web URL with the website URL field.
    expect(find.text('QR Creator'), findsWidgets);
    expect(find.text('Website URL'), findsOneWidget);

    // Placeholder preview before generation.
    expect(find.text('Your QR code will appear here'), findsOneWidget);

    // Enter the Soultech support URL.
    await tester.enterText(find.widgetWithText(TextFormField, 'Website URL'),
        'https://soultech-support.web.app/');
    await tester.pump();

    // Tap Create QR.
    await tester.tap(find.widgetWithText(FilledButton, 'Create QR'));
    await tester.pumpAndSettle();

    // Preview now shows the payload and export buttons.
    expect(find.text('QR Preview'), findsOneWidget);
    expect(find.text('Web URL'), findsWidgets);
    expect(find.text('https://soultech-support.web.app/'), findsWidgets);
    expect(find.text('Save as PNG'), findsOneWidget);
    expect(find.text('Save as PDF'), findsOneWidget);
  });

  testWidgets('QR Creator rejects invalid URL', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: QrCreatorPage()),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Website URL'), 'not a url');
    await tester.tap(find.widgetWithText(FilledButton, 'Create QR'));
    await tester.pumpAndSettle();

    expect(find.text('Invalid URL'), findsOneWidget);
    // No preview/export shown.
    expect(find.text('Save as PNG'), findsNothing);
  });

  testWidgets('Phone type builds tel payload preview', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: QrCreatorPage()),
    );
    await tester.pumpAndSettle();

    // Switch to Phone.
    await tester.tap(find.byType(DropdownButtonFormField<QrDataType>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Phone Number').last);
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Phone Number'), '+218910461043');
    await tester.tap(find.widgetWithText(FilledButton, 'Create QR'));
    await tester.pumpAndSettle();

    expect(find.text('tel:+218910461043'), findsOneWidget);
  });
}
