class SelektSdkConfig {
  const SelektSdkConfig({
    required this.appId,
    required this.baseUrl,
    this.languageCode,
    this.enableLogging = false,
  });

  final String appId;
  final String baseUrl;
  final String? languageCode;
  final bool enableLogging;

  String get normalizedAppId {
    final normalized = appId.trim().toLowerCase();
    if (normalized.isEmpty) {
      throw ArgumentError.value(appId, 'appId', 'appId is required');
    }
    return normalized;
  }
}
