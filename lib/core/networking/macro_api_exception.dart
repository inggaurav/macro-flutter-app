class MacroApiException implements Exception {
  final String message;
  final int? statusCode;

  const MacroApiException(this.message, {this.statusCode});

  @override
  String toString() {
    if (statusCode == null) return message;
    return '$message (HTTP $statusCode)';
  }
}
