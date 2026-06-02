class WishRequest {
  const WishRequest({
    required this.id,
    required this.appId,
    required this.userId,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String appId;
  final String userId;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory WishRequest.fromJson(Map<String, dynamic> json) {
    return WishRequest(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      appId: json['appId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
