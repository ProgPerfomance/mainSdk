class ReferralSummary {
  const ReferralSummary({required this.count, required this.referrals});

  final int count;
  final List<ReferralEntry> referrals;

  factory ReferralSummary.fromJson(Map<String, dynamic> json) {
    final rawReferrals = json['referrals'] as List<dynamic>? ?? const [];
    return ReferralSummary(
      count:
          (json['count'] as num?)?.toInt() ??
          (json['referralsCount'] as num?)?.toInt() ??
          rawReferrals.length,
      referrals: rawReferrals
          .map(
            (item) =>
                ReferralEntry.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'referrals': referrals.map((item) => item.toJson()).toList(),
    };
  }
}

class ReferralEntry {
  const ReferralEntry({
    required this.userId,
    required this.name,
    required this.createdAt,
    this.email,
    this.avatarUrl,
    this.referralCode,
    this.appliedReferralCode,
    this.referralAppliedAt,
  });

  final String userId;
  final String name;
  final String? email;
  final String? avatarUrl;
  final String? referralCode;
  final String? appliedReferralCode;
  final DateTime? referralAppliedAt;
  final DateTime createdAt;

  factory ReferralEntry.fromJson(Map<String, dynamic> json) {
    return ReferralEntry(
      userId: json['_id']?.toString() ?? json['userId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      referralCode: json['referralCode']?.toString(),
      appliedReferralCode: json['appliedReferralCode']?.toString(),
      referralAppliedAt: _parseDateTime(json['referralAppliedAt']),
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': userId,
      'name': name,
      if (email != null) 'email': email,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (referralCode != null) 'referralCode': referralCode,
      if (appliedReferralCode != null)
        'appliedReferralCode': appliedReferralCode,
      if (referralAppliedAt != null)
        'referralAppliedAt': referralAppliedAt!.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value is DateTime) {
      return value.toUtc();
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value)?.toUtc();
    }
    return null;
  }
}
