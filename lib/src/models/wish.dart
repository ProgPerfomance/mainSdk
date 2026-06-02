enum WishReactionType {
  like,
  dislike;

  String get apiValue => switch (this) {
    WishReactionType.like => 'like',
    WishReactionType.dislike => 'dislike',
  };

  static WishReactionType? fromNullable(dynamic value) {
    final normalizedValue = value?.toString().trim().toLowerCase();
    switch (normalizedValue) {
      case 'like':
        return WishReactionType.like;
      case 'dislike':
        return WishReactionType.dislike;
      default:
        return null;
    }
  }
}

class Wish {
  const Wish({
    required this.id,
    this.requestId,
    required this.text,
    required this.likeCount,
    required this.dislikeCount,
    required this.createdAt,
    required this.updatedAt,
    this.userReaction,
  });

  final String id;
  final String? requestId;
  final String text;
  final int likeCount;
  final int dislikeCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final WishReactionType? userReaction;

  factory Wish.fromJson(Map<String, dynamic> json) {
    return Wish(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      requestId: json['requestId']?.toString(),
      text: json['text']?.toString() ?? '',
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      dislikeCount: (json['dislikeCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      userReaction: WishReactionType.fromNullable(json['userReaction']),
    );
  }

  Wish copyWith({
    String? id,
    String? requestId,
    String? text,
    int? likeCount,
    int? dislikeCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    WishReactionType? userReaction,
    bool clearUserReaction = false,
  }) {
    return Wish(
      id: id ?? this.id,
      requestId: requestId ?? this.requestId,
      text: text ?? this.text,
      likeCount: likeCount ?? this.likeCount,
      dislikeCount: dislikeCount ?? this.dislikeCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userReaction: clearUserReaction
          ? null
          : (userReaction ?? this.userReaction),
    );
  }
}
