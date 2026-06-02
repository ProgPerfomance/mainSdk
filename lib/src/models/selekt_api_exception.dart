class SelektApiException implements Exception {
  const SelektApiException({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.details,
  });

  final String message;
  final int? statusCode;
  final String? errorCode;
  final Map<String, dynamic>? details;

  factory SelektApiException.fromResponse({
    required dynamic responseData,
    String? fallbackMessage,
    int? statusCode,
  }) {
    if (responseData is Map) {
      final data = Map<String, dynamic>.from(responseData);
      return SelektApiException(
        message:
            data['errorMessage']?.toString() ??
            data['error']?.toString() ??
            data['message']?.toString() ??
            fallbackMessage ??
            'API request failed',
        statusCode: statusCode,
        errorCode: data['errorCode']?.toString(),
        details: data['details'] is Map
            ? Map<String, dynamic>.from(data['details'] as Map)
            : null,
      );
    }

    return SelektApiException(
      message: fallbackMessage ?? 'API request failed',
      statusCode: statusCode,
    );
  }

  @override
  String toString() => message;
}
