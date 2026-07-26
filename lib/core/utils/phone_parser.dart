import 'dart:ui' show PlatformDispatcher;

import 'package:intl_phone_field/countries.dart';

/// Parsed values for [IntlPhoneField] when editing a phone stored by the API.
typedef ParsedPhoneForField = ({
  String countryIso,
  String localNumber,
  String raw,
});

String stripPhoneFormatting(String value) =>
    value.replaceAll(RegExp(r'[\s\-()]'), '');

/// ISO country code for the phone dropdown when the API value has no `+` prefix.
String deviceCountryIso({String fallback = 'BD'}) {
  final iso = PlatformDispatcher.instance.locale.countryCode?.toUpperCase();
  if (iso != null &&
      iso.length == 2 &&
      countries.any((country) => country.code == iso)) {
    return iso;
  }
  return fallback;
}

/// Maps a backend phone string to country + local segments for [IntlPhoneField].
ParsedPhoneForField parsePhoneForIntlField(
  String raw, {
  String? defaultCountryIso,
}) {
  final trimmed = raw.trim();
  final fallbackIso = defaultCountryIso ?? deviceCountryIso();

  if (trimmed.isEmpty) {
    return (countryIso: fallbackIso, localNumber: '', raw: trimmed);
  }

  if (trimmed.startsWith('+')) {
    final digits = stripPhoneFormatting(trimmed.substring(1));
    final sorted = [...countries]
      ..sort((a, b) => b.dialCode.length.compareTo(a.dialCode.length));
    for (final country in sorted) {
      if (digits.startsWith(country.dialCode)) {
        return (
          countryIso: country.code,
          localNumber: digits.substring(country.dialCode.length),
          raw: trimmed,
        );
      }
    }
    return (
      countryIso: fallbackIso,
      localNumber: stripPhoneFormatting(trimmed),
      raw: trimmed,
    );
  }

  var local = stripPhoneFormatting(trimmed);
  if (local.startsWith('0') && local.length > 1) {
    local = local.substring(1);
  }

  return (countryIso: fallbackIso, localNumber: local, raw: trimmed);
}

({String code, String dialCode}) _countryByIso(String iso) {
  final country = countries.firstWhere(
    (c) => c.code == iso,
    orElse: () => countries.firstWhere((c) => c.code == 'BD'),
  );
  return (code: country.code, dialCode: country.dialCode);
}

/// E.164-style value implied by the parsed country + local number at open time.
String baselineCompleteNumber(ParsedPhoneForField parsed) {
  if (parsed.localNumber.isEmpty) return parsed.raw;
  final dialCode = _countryByIso(parsed.countryIso).dialCode;
  return '+$dialCode${parsed.localNumber}';
}

/// Keeps the API's original formatting when the user did not meaningfully edit phone.
String phoneValueForUpdate({
  required String originalRaw,
  required String completeFromField,
  required String baselineComplete,
}) {
  if (completeFromField.trim().isEmpty) return originalRaw;

  final fromField = stripPhoneFormatting(completeFromField);
  final baseline = stripPhoneFormatting(baselineComplete);
  final original = stripPhoneFormatting(originalRaw);

  if (fromField == baseline || fromField == original) {
    return originalRaw;
  }
  return completeFromField;
}
