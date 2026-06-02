class SelektUser {
  const SelektUser({
    required this.id,
    required this.name,
    required this.email,
    required this.balance,
    required this.requestBalance,
    required this.createdAt,
    required this.updatedAt,
    this.phoneNumber,
    this.referralCode,
    this.appliedReferralCode,
    this.referredByUserId,
    this.referralAppliedAt,
    this.avatarUrl,
    this.subscriptionExpiresAt,
    this.subscriptionAutoRenewEnabled = false,
    this.subscriptionNextChargeAt,
  });

  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? referralCode;
  final String? appliedReferralCode;
  final String? referredByUserId;
  final DateTime? referralAppliedAt;
  final String? avatarUrl;
  final double balance;
  final int requestBalance;
  final DateTime? subscriptionExpiresAt;
  final bool subscriptionAutoRenewEnabled;
  final DateTime? subscriptionNextChargeAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get hasActiveSubscription {
    final expiresAt = subscriptionExpiresAt;
    return expiresAt != null && expiresAt.toUtc().isAfter(DateTime.now().toUtc());
  }

  factory SelektUser.fromJson(Map<String, dynamic> json) {
    return SelektUser(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString(),
      referralCode: json['referralCode']?.toString(),
      appliedReferralCode: json['appliedReferralCode']?.toString(),
      referredByUserId: json['referredByUserId']?.toString(),
      referralAppliedAt: _parseDateTime(json['referralAppliedAt']),
      avatarUrl: json['avatarUrl']?.toString(),
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      requestBalance: (json['requestBalance'] as num?)?.toInt() ?? 0,
      subscriptionExpiresAt: _parseDateTime(json['subscriptionExpiresAt']),
      subscriptionAutoRenewEnabled:
          json['subscriptionAutoRenewEnabled'] == true,
      subscriptionNextChargeAt: _parseDateTime(
        json['subscriptionNextChargeAt'],
      ),
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now().toUtc(),
      updatedAt: _parseDateTime(json['updatedAt']) ?? DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'referralCode': referralCode,
      'appliedReferralCode': appliedReferralCode,
      'referredByUserId': referredByUserId,
      'referralAppliedAt': referralAppliedAt?.toIso8601String(),
      'avatarUrl': avatarUrl,
      'balance': balance,
      'requestBalance': requestBalance,
      'subscriptionExpiresAt': subscriptionExpiresAt?.toIso8601String(),
      'subscriptionAutoRenewEnabled': subscriptionAutoRenewEnabled,
      'subscriptionNextChargeAt': subscriptionNextChargeAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
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
