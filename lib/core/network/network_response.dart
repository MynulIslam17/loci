class NetworkResponse {
  final bool isSuccess;
  final int statusCode;
  final Map<String, dynamic>? body;
  final String? errorMessage;

  /// Machine-readable error code from the error envelope
  /// (`{ "success": false, "message": "...", "code": "SOME_CODE" }`).
  /// Match on this, never on [errorMessage].
  final String? errorCode;

  NetworkResponse({
    required this.isSuccess,
    required this.statusCode,
    this.body,
    this.errorMessage,
    this.errorCode,
  });
}
