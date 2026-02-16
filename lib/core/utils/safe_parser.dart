// parser_helper.dart

class ParserHelper {
  /// Safely get a String (trims extra spaces)
  static String getString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    if (value is String) return value.trim();
    return defaultValue;
  }

  /// Safely get an Integer
  static int getInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) {
      try {
        return int.parse(value.trim());
      } catch (_) {
        return defaultValue;
      }
    }
    return defaultValue;
  }

  /// Safely get a Double
  static double getDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value.trim());
      } catch (_) {
        return defaultValue;
      }
    }
    return defaultValue;
  }

  /// Safely get a DateTime
  static DateTime? getDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value.trim());
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Safely get a Map<String, dynamic>
  static Map<String, dynamic> getStringMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  /// Alias for getStringMap (for better readability)
  static Map<String, dynamic> map(dynamic value) => getStringMap(value);
}