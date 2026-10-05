import 'package:flutter_test/flutter_test.dart';
import 'package:loci/core/utils/date_parser.dart';
import 'package:loci/core/utils/validators.dart';

void main() {
  group('Postal code', () {
    test('accepts common formats without a country selector', () {
      for (final code in ['1207', '10001', '12345-6789', 'SW1A 1AA']) {
        expect(validateZipCode(code), isNull, reason: code);
      }
    });

    test('rejects invalid characters and separators', () {
      for (final code in ['', '12', 'ABC_', '-1207', 'SW1A  1AA']) {
        expect(validateZipCode(code), isNotNull, reason: code);
      }
    });
  });

  group('Signup date of birth', () {
    test('accepts a date at the minimum age', () {
      final today = DateTime.now();
      final oldestAllowedChild = DateTime(
        today.year - 13,
        today.month,
        today.day,
      );

      expect(
        validateDateOfBirth(DateParserHelper.toApiDate(oldestAllowedChild)),
        isNull,
      );
    });

    test('rejects an underage date', () {
      final today = DateTime.now();
      final underageDate = DateTime(today.year - 12, today.month, today.day);

      expect(
        validateDateOfBirth(DateParserHelper.toApiDate(underageDate)),
        isNotNull,
      );
    });

    test('rejects calendar dates that roll into another month', () {
      expect(validateDateOfBirth('2023-02-29'), isNotNull);
      expect(validateDateOfBirth('31/04/2000'), isNotNull);
      expect(validateDateOfBirth('2008-02-29'), isNull);
    });
  });

  test('Login permits an existing password without signup strength rules', () {
    expect(validateLoginPassword('older-password'), isNull);
    expect(validatePassword('older-password'), isNotNull);
  });

  test('Confirmation must exactly match the original password', () {
    expect(validateConfirmPassword(' Abcdef12', ' Abcdef12'), isNull);
    expect(validateConfirmPassword('Abcdef12', ' Abcdef12'), isNotNull);
  });
}
