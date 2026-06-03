import 'request_package.dart';
import 'subscription_settings.dart';

class TBankPaymentInit {
  const TBankPaymentInit({
    required this.paymentId,
    required this.orderId,
    required this.paymentUrl,
    required this.amount,
    required this.amountKopecks,
    this.status,
    this.requestPackage,
    this.subscription,
    this.autoRenew = false,
  });

  final String paymentId;
  final String orderId;
  final String paymentUrl;
  final double amount;
  final int amountKopecks;
  final String? status;
  final RequestPackage? requestPackage;
  final SubscriptionSettings? subscription;
  final bool autoRenew;

  factory TBankPaymentInit.fromJson(Map<String, dynamic> json) {
    return TBankPaymentInit(
      paymentId: json['paymentId']?.toString() ?? '',
      orderId: json['orderId']?.toString() ?? '',
      paymentUrl: json['paymentUrl']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      amountKopecks: (json['amountKopecks'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString(),
      requestPackage: json['package'] is Map
          ? RequestPackage.fromJson(
              Map<String, dynamic>.from(json['package'] as Map),
            )
          : null,
      subscription: json['subscription'] is Map
          ? SubscriptionSettings.fromJson(
              Map<String, dynamic>.from(json['subscription'] as Map),
            )
          : null,
      autoRenew: json['autoRenew'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentId': paymentId,
      'orderId': orderId,
      'paymentUrl': paymentUrl,
      'amount': amount,
      'amountKopecks': amountKopecks,
      if (status != null) 'status': status,
      if (requestPackage != null) 'package': requestPackage!.toJson(),
      if (subscription != null) 'subscription': subscription!.toJson(),
      'autoRenew': autoRenew,
    };
  }
}

class TBankPaymentConfirm {
  const TBankPaymentConfirm({
    required this.paymentId,
    required this.orderId,
    required this.status,
    required this.confirmed,
    required this.applied,
    this.newBalance,
    this.paidAmount,
    this.bonusAmount,
    this.creditedAmount,
    this.newRequestBalance,
    this.subscriptionExpiresAt,
    this.autoRenew = false,
  });

  final String paymentId;
  final String orderId;
  final String status;
  final bool confirmed;
  final bool applied;
  final double? newBalance;
  final double? paidAmount;
  final double? bonusAmount;
  final double? creditedAmount;
  final int? newRequestBalance;
  final DateTime? subscriptionExpiresAt;
  final bool autoRenew;

  factory TBankPaymentConfirm.fromJson(Map<String, dynamic> json) {
    return TBankPaymentConfirm(
      paymentId: json['paymentId']?.toString() ?? '',
      orderId: json['orderId']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      confirmed: json['confirmed'] == true,
      applied: json['applied'] == true,
      newBalance: (json['newBalance'] as num?)?.toDouble(),
      paidAmount: (json['paidAmount'] as num?)?.toDouble(),
      bonusAmount: (json['bonusAmount'] as num?)?.toDouble(),
      creditedAmount: (json['creditedAmount'] as num?)?.toDouble(),
      newRequestBalance: (json['newRequestBalance'] as num?)?.toInt(),
      subscriptionExpiresAt: _parseDateTime(json['subscriptionExpiresAt']),
      autoRenew: json['autoRenew'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentId': paymentId,
      'orderId': orderId,
      'status': status,
      'confirmed': confirmed,
      'applied': applied,
      if (newBalance != null) 'newBalance': newBalance,
      if (paidAmount != null) 'paidAmount': paidAmount,
      if (bonusAmount != null) 'bonusAmount': bonusAmount,
      if (creditedAmount != null) 'creditedAmount': creditedAmount,
      if (newRequestBalance != null) 'newRequestBalance': newRequestBalance,
      if (subscriptionExpiresAt != null)
        'subscriptionExpiresAt': subscriptionExpiresAt!.toIso8601String(),
      'autoRenew': autoRenew,
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
