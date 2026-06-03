class RequestPackage {
  const RequestPackage({
    required this.id,
    required this.requestCount,
    required this.price,
    required this.isActive,
    required this.appIds,
    this.appId,
    this.scope = 'app',
  });

  final String id;
  final int requestCount;
  final double price;
  final bool isActive;
  final String? appId;
  final String scope;
  final List<String> appIds;

  bool get isGlobal => scope.trim().toLowerCase() == 'global';

  double get pricePerRequest => requestCount <= 0 ? 0 : price / requestCount;

  factory RequestPackage.fromJson(Map<String, dynamic> json) {
    final rawAppIds = json['appIds'] ?? json['app_ids'];
    return RequestPackage(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      requestCount: (json['requestCount'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      isActive: json['isActive'] != false,
      appId: json['appId']?.toString() ?? json['app_id']?.toString(),
      scope: json['scope']?.toString() ?? 'app',
      appIds: rawAppIds is List
          ? rawAppIds.map((item) => item.toString()).toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'requestCount': requestCount,
      'price': price,
      'isActive': isActive,
      if (appId != null) 'appId': appId,
      if (appId != null) 'app_id': appId,
      'scope': scope,
      'appIds': appIds,
      'app_ids': appIds,
    };
  }
}

class RequestPackagePurchase {
  const RequestPackagePurchase({
    required this.package,
    required this.newBalance,
    required this.newRequestBalance,
  });

  final RequestPackage package;
  final double newBalance;
  final int newRequestBalance;

  factory RequestPackagePurchase.fromJson(Map<String, dynamic> json) {
    return RequestPackagePurchase(
      package: RequestPackage.fromJson(
        Map<String, dynamic>.from(json['package'] as Map),
      ),
      newBalance: (json['newBalance'] as num?)?.toDouble() ?? 0,
      newRequestBalance: (json['newRequestBalance'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'package': package.toJson(),
      'newBalance': newBalance,
      'newRequestBalance': newRequestBalance,
    };
  }
}
