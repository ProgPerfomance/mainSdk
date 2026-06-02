class AppVersionSettings {
  const AppVersionSettings({
    required this.requiredVersion,
    required this.updatedAt,
  });

  final String requiredVersion;
  final DateTime updatedAt;

  factory AppVersionSettings.fromJson(Map<String, dynamic> json) {
    return AppVersionSettings(
      requiredVersion: json['requiredVersion']?.toString().trim() ?? '',
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
