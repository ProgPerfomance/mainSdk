class SubscriptionSettings {
  const SubscriptionSettings({
    required this.name,
    required this.price,
    required this.periodDays,
    this.id,
    this.appId,
    this.scope = 'app',
  });

  final String? id;
  final String name;
  final double price;
  final int periodDays;
  final String? appId;
  final String scope;

  bool get isGlobal => scope.trim().toLowerCase() == 'global';

  factory SubscriptionSettings.fromJson(Map<String, dynamic> json) {
    return SubscriptionSettings(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      name: json['name']?.toString() ?? 'Subscription',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      periodDays: (json['periodDays'] as num?)?.toInt() ?? 30,
      appId: json['appId']?.toString() ?? json['app_id']?.toString(),
      scope: json['scope']?.toString() ?? 'app',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'price': price,
      'periodDays': periodDays,
      if (appId != null) 'appId': appId,
      if (appId != null) 'app_id': appId,
      'scope': scope,
    };
  }
}
