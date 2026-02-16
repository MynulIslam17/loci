class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Clean Architecture App';
  static const String appVersion = '1.0.0';

  // API
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Database
  static const String databaseName = 'clean_architecture.db';
  static const int databaseVersion = 1;

  // Tables
  static const String usersTable = 'users';
  static const String postsTable = 'posts';

  // Secure Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String refreshTokenKey = 'refresh_token';

  // Pagination
  static const int defaultPageSize = 20;
}
