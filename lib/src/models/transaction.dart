enum SelektTransactionType { deposit, withdrawal, payment }

class SelektTransaction {
  const SelektTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.createdAt,
    this.userName,
    this.description,
    this.metadata,
  });

  final String id;
  final String userId;
  final String? userName;
  final double amount;
  final SelektTransactionType type;
  final String? description;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  factory SelektTransaction.fromJson(Map<String, dynamic> json) {
    return SelektTransaction(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      userName: json['userName']?.toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      type: SelektTransactionType.values.firstWhere(
        (item) => item.name == json['type']?.toString(),
        orElse: () => SelektTransactionType.deposit,
      ),
      description: json['description']?.toString(),
      metadata: json['metadata'] is Map
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      if (userName != null) 'userName': userName,
      'amount': amount,
      'type': type.name,
      if (description != null) 'description': description,
      if (metadata != null) 'metadata': metadata,
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
