enum RelatedAppsBlockType {
  grid,
  banner;

  static RelatedAppsBlockType fromJson(dynamic value) {
    return switch (value?.toString()) {
      'banner' => RelatedAppsBlockType.banner,
      _ => RelatedAppsBlockType.grid,
    };
  }

  String get apiValue {
    return switch (this) {
      RelatedAppsBlockType.grid => 'grid',
      RelatedAppsBlockType.banner => 'banner',
    };
  }
}

class RelatedApp {
  const RelatedApp({
    required this.appId,
    required this.name,
    required this.title,
    this.displayName,
    this.shortDescription,
    this.imageUrl,
    this.ruStoreUrl,
    this.platform,
    this.apiBaseUrl,
  });

  final String appId;
  final String name;
  final String title;
  final String? displayName;
  final String? shortDescription;
  final String? imageUrl;
  final String? ruStoreUrl;
  final String? platform;
  final String? apiBaseUrl;

  factory RelatedApp.fromJson(Map<String, dynamic> json) {
    final name = json['name']?.toString() ?? '';
    final displayName = json['displayName']?.toString();
    return RelatedApp(
      appId: json['appId']?.toString() ?? json['app_id']?.toString() ?? '',
      name: name,
      title: json['title']?.toString() ?? displayName ?? name,
      displayName: displayName,
      shortDescription: json['shortDescription']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      ruStoreUrl: json['ruStoreUrl']?.toString(),
      platform: json['platform']?.toString(),
      apiBaseUrl: json['apiBaseUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appId': appId,
      'app_id': appId,
      'name': name,
      'title': title,
      if (displayName != null) 'displayName': displayName,
      if (shortDescription != null) 'shortDescription': shortDescription,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (ruStoreUrl != null) 'ruStoreUrl': ruStoreUrl,
      if (platform != null) 'platform': platform,
      if (apiBaseUrl != null) 'apiBaseUrl': apiBaseUrl,
    };
  }
}

class RelatedAppsBlock {
  const RelatedAppsBlock({
    required this.type,
    required this.apps,
    this.title,
    this.columns = 3,
  });

  final RelatedAppsBlockType type;
  final List<RelatedApp> apps;
  final String? title;
  final int columns;

  bool get isBanner => type == RelatedAppsBlockType.banner;
  bool get isGrid => type == RelatedAppsBlockType.grid;

  factory RelatedAppsBlock.fromJson(Map<String, dynamic> json) {
    final apps = json['apps'] is List
        ? (json['apps'] as List)
              .whereType<Map>()
              .map(
                (item) => RelatedApp.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()
        : <RelatedApp>[];
    return RelatedAppsBlock(
      type: RelatedAppsBlockType.fromJson(json['type']),
      title: json['title']?.toString(),
      columns: (json['columns'] as num?)?.toInt() ?? 3,
      apps: apps,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.apiValue,
      if (title != null) 'title': title,
      'columns': columns,
      'apps': apps.map((app) => app.toJson()).toList(),
    };
  }
}

class RelatedAppsFeed {
  const RelatedAppsFeed({required this.blocks, this.appId});

  final String? appId;
  final List<RelatedAppsBlock> blocks;

  List<RelatedApp> get apps {
    return blocks.expand((block) => block.apps).toList();
  }

  factory RelatedAppsFeed.fromJson(Map<String, dynamic> json) {
    final blocks = json['blocks'] is List
        ? (json['blocks'] as List)
              .whereType<Map>()
              .map(
                (item) =>
                    RelatedAppsBlock.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()
        : <RelatedAppsBlock>[];
    return RelatedAppsFeed(
      appId: json['appId']?.toString() ?? json['app_id']?.toString(),
      blocks: blocks,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (appId != null) 'appId': appId,
      if (appId != null) 'app_id': appId,
      'blocks': blocks.map((block) => block.toJson()).toList(),
    };
  }
}
