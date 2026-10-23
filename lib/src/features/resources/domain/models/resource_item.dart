class GrantResource {
  const GrantResource({
    required this.name,
    required this.amount,
    required this.deadline,
    required this.description,
    required this.eligibility,
    required this.url,
    required this.relevanceScore,
  });

  final String name;
  final String amount;
  final String deadline;
  final String description;
  final String eligibility;
  final String url;
  final int relevanceScore;

  factory GrantResource.fromMap(Map<String, dynamic> map) {
    return GrantResource(
      name: map['name'] as String? ?? '',
      amount: map['amount'] as String? ?? '',
      deadline: map['deadline'] as String? ?? '',
      description: map['description'] as String? ?? '',
      eligibility: map['eligibility'] as String? ?? '',
      url: map['url'] as String? ?? '',
      relevanceScore: (map['relevanceScore'] as num?)?.toInt() ?? 0,
    );
  }
}

class ToolResource {
  const ToolResource({
    required this.name,
    required this.category,
    required this.description,
    required this.url,
    required this.isFree,
  });

  final String name;
  final String category;
  final String description;
  final String url;
  final bool isFree;

  factory ToolResource.fromMap(Map<String, dynamic> map) {
    return ToolResource(
      name: map['name'] as String? ?? '',
      category: map['category'] as String? ?? '',
      description: map['description'] as String? ?? '',
      url: map['url'] as String? ?? '',
      isFree: map['isFree'] as bool? ?? false,
    );
  }
}

class FounderTip {
  const FounderTip({
    required this.title,
    required this.body,
    required this.category,
  });

  final String title;
  final String body;
  final String category;

  factory FounderTip.fromMap(Map<String, dynamic> map) {
    return FounderTip(
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      category: map['category'] as String? ?? '',
    );
  }

  String get categoryEmoji => switch (category) {
    'funding' => '💰',
    'growth' => '📈',
    'networking' => '🤝',
    'operations' => '⚙️',
    _ => '✨',
  };
}

class ResourcesResult {
  const ResourcesResult({
    required this.grants,
    required this.tools,
    required this.tips,
    required this.generatedAt,
    required this.fromCache,
  });

  final List<GrantResource> grants;
  final List<ToolResource> tools;
  final List<FounderTip> tips;
  final String generatedAt;
  final bool fromCache;

  factory ResourcesResult.fromMap(Map<String, dynamic> map) {
    return ResourcesResult(
      grants: (map['grants'] as List<dynamic>? ?? [])
          .map((e) => GrantResource.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      tools: (map['tools'] as List<dynamic>? ?? [])
          .map((e) => ToolResource.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      tips: (map['tips'] as List<dynamic>? ?? [])
          .map((e) => FounderTip.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      generatedAt: map['generatedAt'] as String? ?? '',
      fromCache: map['fromCache'] as bool? ?? false,
    );
  }
}
