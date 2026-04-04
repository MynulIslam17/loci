

import 'package:intl_phone_field/phone_number.dart';

/// Standalone Validation Functions
/// Use these directly in your validators like: validator: (value) => validateEmail(value)

// ==================== NAME VALIDATORS ====================

/// Validates first name
String? validateFirstName(String? value) {
  return _validateName(value, fieldName: "First name");
}

/// Validates last name
String? validateLastName(String? value) {
  return _validateName(value, fieldName: "Last name");
}

/// Validates middle name (optional field)
String? validateMiddleName(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null; // Optional field
  }
  return _validateName(value, fieldName: "Middle name");
}

/// Internal name validation logic
String? _validateName(String? value, {required String fieldName}) {
  if (value == null || value.trim().isEmpty) {
    return "Name is required";
  }

  final trimmedValue = value.trim();

  if (trimmedValue.length < 2) {
    return "Name is too short";
  }

  if (trimmedValue.length > 50) {
    return "$fieldName must be less than 50 characters";
  }

  // Disallow multiple consecutive spaces
  if (trimmedValue.contains(RegExp(r'\s{2,}'))) {
    return "$fieldName cannot contain multiple consecutive spaces";
  }

  // Allow letters, spaces, hyphens, apostrophes (including international chars)
  if (!RegExp(r"^[\p{L}]+(?:[\s\-'][\p{L}]+)*$", unicode: true)
      .hasMatch(trimmedValue)) {
    return "$fieldName can only contain letters, spaces, hyphens, or apostrophes";
  }

  return null; // ✅ Valid
}

// ==================== EMAIL VALIDATOR ====================

/// Validates email address
String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return "Email is required";
  }

  final trimmedValue = value.trim();

  // Email regex pattern
  final emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  if (!emailRegex.hasMatch(trimmedValue)) {
    return "Please enter a valid email address";
  }

  return null; // ✅ Valid
}

// ==================== PASSWORD VALIDATORS ====================

/// Validates password with default requirements
/// Min 8 chars, uppercase, lowercase, number, special char
String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return "Password is required";
  }

  if (value.length < 6) {
    return "Password must be at least 6 characters";
  }

  // if (!value.contains(RegExp(r'[A-Z]'))) {
  //   return "Password must contain at least one uppercase letter";
  // }
  //
  // if (!value.contains(RegExp(r'[a-z]'))) {
  //   return "Password must contain at least one lowercase letter";
  // }
  //
  // if (!value.contains(RegExp(r'[0-9]'))) {
  //   return "Password must contain at least one number";
  // }
  //
  // if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
  //   return "Password must contain at least one special character";
  // }

  return null;
}

/// Validates password with custom length (no complexity requirements)
String? validatePasswordSimple(String? value, {int minLength = 6}) {
  if (value == null || value.isEmpty) {
    return "Password is required";
  }


  if (value.length < minLength) {
    return "Password must be at least $minLength characters";
  }

  return null;
}

/// Validates confirm password
String? validateConfirmPassword(String? value, String? password) {
  if (value == null || value.isEmpty) {
    return "Please confirm your password";
  }

  if (value != password) {
    return "Passwords do not match";
  }

  return null;
}

// ==================== PHONE VALIDATOR ====================

/// Validates phone number (for IntlPhoneField)
String? validatePhoneNumber(PhoneNumber? phoneNumber) {
  if (phoneNumber == null || phoneNumber.number.isEmpty) {
    return "Phone number is required";
  }

  // IntlPhoneField handles country-specific validation automatically
  return null;
}

// ==================== DATE VALIDATORS ====================

/// Validates date of birth (must be 18+ years old)

String? validateDateOfBirth(String? value, {int minAge = 13}) {
  if (value == null || value.trim().isEmpty) {
    return "Date of birth is required";
  }

  try {
    DateTime date;

    // ✅ FIRST: Handle ISO format strictly (YYYY-MM-DD)
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
      date = DateTime.parse(value);
    }

    // ✅ THEN: Handle DD/MM/YYYY or DD-MM-YYYY
    else if (RegExp(r'^\d{2}[/\-]\d{2}[/\-]\d{4}$').hasMatch(value)) {
      final parts = value.split(RegExp(r'[/\-]'));
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      date = DateTime(year, month, day);
    }

    // ❌ Anything else → invalid
    else {
      return "Invalid date format";
    }

    final now = DateTime.now();

    final age = now.year - date.year -
        ((now.month > date.month ||
            (now.month == date.month && now.day >= date.day))
            ? 0
            : 1);

    if (date.isAfter(now)) return "Date of birth cannot be in the future";
    if (age < minAge) return "You must be at least $minAge years old";
    if (age > 120) return "Please enter a valid date of birth";

    return null; // ✅ valid
  } catch (e) {
    return "Please enter a valid date";
  }
}

/// Validates any date field
String? validateDate(String? value, {String? fieldName}) {
  final name = fieldName ?? "Date";

  if (value == null || value.trim().isEmpty) {
    return "$name is required";
  }

  try {
    DateTime.parse(value);
    return null;
  } catch (e) {
    return "Please enter a valid date";
  }
}

// ==================== USERNAME VALIDATOR ====================

/// Validates username (alphanumeric, underscores, hyphens)
String? validateUsername(String? value, {int minLength = 3, int maxLength = 20}) {
  if (value == null || value.trim().isEmpty) {
    return "Username is required";
  }

  final trimmedValue = value.trim();

  if (trimmedValue.length < minLength) {
    return "Username must be at least $minLength characters";
  }

  if (trimmedValue.length > maxLength) {
    return "Username must be less than $maxLength characters";
  }

  // Allow letters, numbers, underscores, hyphens
  if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(trimmedValue)) {
    return "Username can only contain letters, numbers, underscores, and hyphens";
  }

  // Don't allow starting/ending with special chars
  if (RegExp(r'^[_-]|[_-]$').hasMatch(trimmedValue)) {
    return "Username cannot start or end with underscore or hyphen";
  }

  return null;
}

// ==================== TEXT VALIDATORS ====================

/// Validates required field
String? validateRequired(String? value, {String? fieldName}) {
  final name = fieldName ?? "This field";

  if (value == null || value.trim().isEmpty) {
    return "$name is required";
  }

  return null;
}

/// Validates minimum length
String? validateMinLength(String? value, int minLength, {String? fieldName}) {
  final name = fieldName ?? "This field";

  if (value == null || value.trim().isEmpty) {
    return "$name is required";
  }

  if (value.trim().length < minLength) {
    return "$name must be at least $minLength characters";
  }

  return null;
}

/// Validates maximum length
String? validateMaxLength(String? value, int maxLength, {String? fieldName}) {
  if (value == null) return null; // Allow empty if not required

  final name = fieldName ?? "This field";

  if (value.trim().length > maxLength) {
    return "$name must be less than $maxLength characters";
  }

  return null;
}

// ==================== NUMBER VALIDATORS ====================

/// Validates numeric input
String? validateNumber(String? value, {String? fieldName}) {
  final name = fieldName ?? "This field";

  if (value == null || value.trim().isEmpty) {
    return "$name is required";
  }

  if (int.tryParse(value.trim()) == null && double.tryParse(value.trim()) == null) {
    return "$name must be a valid number";
  }

  return null;
}

/// Validates integer
String? validateInteger(String? value, {String? fieldName}) {
  final name = fieldName ?? "This field";

  if (value == null || value.trim().isEmpty) {
    return "$name is required";
  }

  if (int.tryParse(value.trim()) == null) {
    return "$name must be a valid whole number";
  }

  return null;
}

/// Validates number in a range
String? validateNumberInRange(
    String? value,
    num min,
    num max, {
      String? fieldName,
    }) {
  final name = fieldName ?? "This field";

  if (value == null || value.trim().isEmpty) {
    return "$name is required";
  }

  final number = num.tryParse(value.trim());

  if (number == null) {
    return "$name must be a valid number";
  }

  if (number < min || number > max) {
    return "$name must be between $min and $max";
  }

  return null;
}

// ==================== URL VALIDATOR ====================

/// Validates URL
String? validateUrl(String? value, {String? fieldName}) {
  final name = fieldName ?? "URL";

  if (value == null || value.trim().isEmpty) {
    return "$name is required";
  }

  final urlPattern = RegExp(
    r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
  );

  if (!urlPattern.hasMatch(value.trim())) {
    return "Please enter a valid URL";
  }

  return null; // ✅ Valid
}

// ==================== CUSTOM PATTERN VALIDATOR ====================

/// Validates using custom regex pattern
String? validatePattern(
    String? value,
    RegExp pattern, {
      String? fieldName,
      String? errorMessage,
    }) {
  final name = fieldName ?? "This field";

  if (value == null || value.trim().isEmpty) {
    return "$name is required";
  }

  if (!pattern.hasMatch(value.trim())) {
    return errorMessage ?? "$name is invalid";
  }

  return null;
}

// ==================== OPTIONAL VALIDATORS ====================

/// Validates email but allows empty (optional field)
String? validateEmailOptional(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null; // Optional field
  }
  return validateEmail(value);
}

/// Validates phone but allows empty (optional field)
String? validatePhoneOptional(PhoneNumber? phoneNumber) {
  if (phoneNumber == null || phoneNumber.number.isEmpty) {
    return null; // Optional field
  }
  return validatePhoneNumber(phoneNumber);
}

String? validateZipCode(String? value, {int length = 5}) {
  if (value == null || value.trim().isEmpty) {
    return "Zip code is required";
  }

  final trimmedValue = value.trim();

  if (trimmedValue.length < length) {
    return "Zip code must be at least $length characters";
  }

  if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(trimmedValue)) {
    return "Zip code can only contain letters and numbers";
  }

  return null;
}