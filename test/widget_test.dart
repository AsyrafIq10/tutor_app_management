import 'package:flutter_test/flutter_test.dart';
import 'package:tutor_app_management/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('rejects empty', () => expect(Validators.email(''), isNotNull));
    test('rejects bad format',
            () => expect(Validators.email('cath@'), isNotNull));
    test('accepts valid', () => expect(Validators.email('cath@example.com'), isNull));
  });

  group('Validators.password', () {
    test('rejects empty', () => expect(Validators.password(''), isNotNull));
    test('accepts text', () => expect(Validators.password('Tones-2026'), isNull));
  });
}