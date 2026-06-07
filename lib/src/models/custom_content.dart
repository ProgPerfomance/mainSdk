class CustomContentCollection {
  const CustomContentCollection({
    required this.id,
    required this.appId,
    required this.collectionKey,
    required this.name,
    this.description,
    this.schema = const {},
    this.settings = const {},
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String appId;
  final String collectionKey;
  final String name;
  final String? description;
  final Map<String, dynamic> schema;
  final Map<String, dynamic> settings;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory CustomContentCollection.fromJson(Map<String, dynamic> json) {
    return CustomContentCollection(
      id: json['_id']?.toString() ?? '',
      appId: json['appId']?.toString() ?? json['app_id']?.toString() ?? '',
      collectionKey:
          json['collectionKey']?.toString() ?? json['key']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      schema: Map<String, dynamic>.from((json['schema'] as Map?) ?? const {}),
      settings: Map<String, dynamic>.from(
        (json['settings'] as Map?) ?? const {},
      ),
      isActive: json['isActive'] != false,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }
}

class CustomContentItem {
  const CustomContentItem({
    required this.id,
    required this.appId,
    required this.collectionKey,
    required this.itemId,
    required this.title,
    this.description,
    this.imageUrl,
    this.data = const {},
    this.tags = const [],
    this.sortOrder = 0,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String appId;
  final String collectionKey;
  final String itemId;
  final String title;
  final String? description;
  final String? imageUrl;
  final Map<String, dynamic> data;
  final List<String> tags;
  final int sortOrder;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory CustomContentItem.fromJson(Map<String, dynamic> json) {
    return CustomContentItem(
      id: json['_id']?.toString() ?? '',
      appId: json['appId']?.toString() ?? json['app_id']?.toString() ?? '',
      collectionKey:
          json['collectionKey']?.toString() ??
          json['collection_key']?.toString() ??
          '',
      itemId: json['itemId']?.toString() ?? json['slug']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      imageUrl: json['imageUrl']?.toString() ?? json['image_url']?.toString(),
      data: Map<String, dynamic>.from((json['data'] as Map?) ?? const {}),
      tags: (json['tags'] as List? ?? const [])
          .map((item) => item.toString())
          .toList(),
      sortOrder:
          (json['sortOrder'] as num?)?.toInt() ??
          (json['sort_order'] as num?)?.toInt() ??
          0,
      isActive: json['isActive'] != false,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }
}
