import 'transaction.dart';

class BillingHistory {
  const BillingHistory({
    required this.balance,
    required this.requestBalance,
    required this.transactions,
  });

  final double balance;
  final int requestBalance;
  final List<SelektTransaction> transactions;

  factory BillingHistory.fromJson(Map<String, dynamic> json) {
    final rawTransactions = json['transactions'] as List<dynamic>? ?? const [];
    return BillingHistory(
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      requestBalance: (json['requestBalance'] as num?)?.toInt() ?? 0,
      transactions: rawTransactions
          .map(
            (item) => SelektTransaction.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'requestBalance': requestBalance,
      'transactions': transactions.map((item) => item.toJson()).toList(),
    };
  }
}
