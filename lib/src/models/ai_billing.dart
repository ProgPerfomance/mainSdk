class AiRequestPreparation {
  const AiRequestPreparation({
    required this.userId,
    required this.requestPrice,
    required this.willUseRequestBalance,
    required this.hasActiveSubscription,
    required this.sessionStartedAt,
    required this.sessionRequestIndex,
    required this.paymentSource,
    required this.appId,
    this.userName,
  });

  final String userId;
  final String? userName;
  final double requestPrice;
  final bool willUseRequestBalance;
  final bool hasActiveSubscription;
  final DateTime sessionStartedAt;
  final int sessionRequestIndex;
  final String paymentSource;
  final String appId;

  factory AiRequestPreparation.fromJson(Map<String, dynamic> json) {
    return AiRequestPreparation(
      userId: json['userId']?.toString() ?? '',
      userName: json['userName']?.toString(),
      requestPrice: (json['requestPrice'] as num?)?.toDouble() ?? 0,
      willUseRequestBalance: json['willUseRequestBalance'] == true,
      hasActiveSubscription: json['hasActiveSubscription'] == true,
      sessionStartedAt:
          DateTime.tryParse(
            json['sessionStartedAt']?.toString() ?? '',
          )?.toUtc() ??
          DateTime.now().toUtc(),
      sessionRequestIndex: (json['sessionRequestIndex'] as num?)?.toInt() ?? 1,
      paymentSource: json['paymentSource']?.toString() ?? 'balance',
      appId: json['appId']?.toString() ?? json['app_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      if (userName != null) 'userName': userName,
      'requestPrice': requestPrice,
      'willUseRequestBalance': willUseRequestBalance,
      'hasActiveSubscription': hasActiveSubscription,
      'sessionStartedAt': sessionStartedAt.toIso8601String(),
      'sessionRequestIndex': sessionRequestIndex,
      'paymentSource': paymentSource,
      'appId': appId,
      'app_id': appId,
    };
  }
}

class AiRequestCharge {
  const AiRequestCharge({
    required this.newBalance,
    required this.newRequestBalance,
    required this.paymentSource,
  });

  final double newBalance;
  final int newRequestBalance;
  final String paymentSource;

  factory AiRequestCharge.fromJson(Map<String, dynamic> json) {
    return AiRequestCharge(
      newBalance: (json['newBalance'] as num?)?.toDouble() ?? 0,
      newRequestBalance: (json['newRequestBalance'] as num?)?.toInt() ?? 0,
      paymentSource: json['paymentSource']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'newBalance': newBalance,
      'newRequestBalance': newRequestBalance,
      'paymentSource': paymentSource,
    };
  }
}
