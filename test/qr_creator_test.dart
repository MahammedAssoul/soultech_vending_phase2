import 'package:flutter_test/flutter_test.dart';
import 'package:soultech_vending/core/localization/app_strings.dart';
import 'package:soultech_vending/features/qr_creator/qr_data_type.dart';
import 'package:soultech_vending/features/qr_creator/qr_payload_builder.dart';

void main() {
  group('QrPayloadBuilder', () {
    group('Web URL', () {
      test('returns the URL unchanged for https', () {
        final input = QrInput(
          type: QrDataType.webUrl,
          url: 'https://soultech-support.web.app/',
        );
        expect(QrPayloadBuilder.buildPayload(input),
            'https://soultech-support.web.app/');
      });

      test('keeps http URLs as-is', () {
        final input = QrInput(
          type: QrDataType.webUrl,
          url: 'http://example.com/foo',
        );
        expect(QrPayloadBuilder.buildPayload(input), 'http://example.com/foo');
      });

      test('normalizes a URL missing https://', () {
        final input = QrInput(
          type: QrDataType.webUrl,
          url: 'soultech-support.web.app',
        );
        expect(QrPayloadBuilder.buildPayload(input),
            'https://soultech-support.web.app');
      });
    });

    group('Phone', () {
      test('builds tel: payload', () {
        final input = QrInput(
          type: QrDataType.phone,
          phone: '+218910461043',
        );
        expect(QrPayloadBuilder.buildPayload(input), 'tel:+218910461043');
      });
    });

    group('Text', () {
      test('payload is exactly the text', () {
        final input = QrInput(
          type: QrDataType.text,
          text: 'Hello from Soultech Vending',
        );
        expect(QrPayloadBuilder.buildPayload(input),
            'Hello from Soultech Vending');
      });
    });

    group('Email', () {
      test('mailto with no subject/message', () {
        final input = QrInput(
          type: QrDataType.email,
          email: 'soultech4vending@gmail.com',
        );
        expect(QrPayloadBuilder.buildPayload(input),
            'mailto:soultech4vending@gmail.com');
      });

      test('mailto with subject and body (URL-encoded)', () {
        final input = QrInput(
          type: QrDataType.email,
          email: 'soultech4vending@gmail.com',
          subject: 'Support',
          message: 'Hello World',
        );
        expect(
            QrPayloadBuilder.buildPayload(input),
            'mailto:soultech4vending@gmail.com'
            '?subject=Support&body=Hello%20World');
      });

      test('mailto encodes special characters', () {
        final input = QrInput(
          type: QrDataType.email,
          email: 'a@b.com',
          subject: 'need help',
          message: 'a & b',
        );
        final payload = QrPayloadBuilder.buildPayload(input);
        expect(payload, startsWith('mailto:a@b.com?'));
        expect(payload, contains('subject=need%20help'));
        expect(payload, contains('body=a%20%26%20b'));
      });
    });

    group('SMS', () {
      test('sms with phone only', () {
        final input = QrInput(
          type: QrDataType.sms,
          phone: '+218910461043',
        );
        expect(QrPayloadBuilder.buildPayload(input), 'sms:+218910461043');
      });

      test('sms with body (URL-encoded)', () {
        final input = QrInput(
          type: QrDataType.sms,
          phone: '+218910461043',
          message: 'Hello',
        );
        expect(QrPayloadBuilder.buildPayload(input),
            'sms:+218910461043?body=Hello');
      });

      test('sms encodes spaces/symbols', () {
        final input = QrInput(
          type: QrDataType.sms,
          phone: '+218910461043',
          message: 'Hi there!',
        );
        expect(QrPayloadBuilder.buildPayload(input),
            'sms:+218910461043?body=Hi%20there!');
      });
    });

    group('Validation', () {
      test('web URL: empty → required', () {
        final input = QrInput(type: QrDataType.webUrl, url: '');
        expect(QrPayloadBuilder.validate(input), L.requiredField);
      });

      test('web URL: invalid → invalidUrl', () {
        final input = QrInput(type: QrDataType.webUrl, url: 'not a url');
        expect(QrPayloadBuilder.validate(input), L.invalidUrl);
      });

      test('web URL: valid passes', () {
        final input = QrInput(
            type: QrDataType.webUrl, url: 'https://soultech-support.web.app/');
        expect(QrPayloadBuilder.validate(input), isNull);
      });

      test('phone: too short → invalidPhone', () {
        final input = QrInput(type: QrDataType.phone, phone: '123');
        expect(QrPayloadBuilder.validate(input), L.invalidPhone);
      });

      test('phone: valid passes', () {
        final input = QrInput(type: QrDataType.phone, phone: '+218910461043');
        expect(QrPayloadBuilder.validate(input), isNull);
      });

      test('email: invalid → invalidUrl', () {
        final input = QrInput(type: QrDataType.email, email: 'nope');
        expect(QrPayloadBuilder.validate(input), L.invalidUrl);
      });

      test('email: valid passes', () {
        final input = QrInput(
            type: QrDataType.email, email: 'soultech4vending@gmail.com');
        expect(QrPayloadBuilder.validate(input), isNull);
      });

      test('text: empty → required', () {
        final input = QrInput(type: QrDataType.text, text: '  ');
        expect(QrPayloadBuilder.validate(input), L.requiredField);
      });
    });
  });

  group('QrTypes metadata', () {
    test('default type is webUrl', () {
      expect(const QrInput(type: QrDataType.webUrl).type, QrDataType.webUrl);
    });

    test('all types have localized labels', () {
      for (final t in QrTypes.all) {
        expect(t.label, isNotEmpty);
      }
    });

    test('localized labels switch with language', () {
      AppLang.current = 'ar';
      expect(QrTypes.localize(QrDataType.webUrl), 'رابط ويب');
      AppLang.current = 'en';
      expect(QrTypes.localize(QrDataType.webUrl), 'Web URL');
    });
  });
}
