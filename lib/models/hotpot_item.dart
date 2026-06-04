/// 食材的四个状态
enum HotpotState {
  idle, // 未下锅：外圈黑色
  counting, // 煮熟中：外圈黄色闪烁
  ready, // 完美熟透：外圈绿色常亮
  overcooked, // 严重超时：外圈红色高频闪烁
}

/// 单个食材的静态配置 + 运行时状态
class HotpotItem {
  final String id;
  final String name;
  final String category;
  final int targetSeconds; // 推荐煮制时间（秒）
  final List<String> aliases;

  /// 本地图片路径（如 assets/images/maodu.png），为空时用 emoji 兜底
  final String? imagePath;

  /// 没有图片时显示的 emoji，保证空资源也能好看地渲染
  final String emoji;

  HotpotItem({
    required this.id,
    required this.name,
    required this.category,
    required this.targetSeconds,
    this.aliases = const [],
    this.imagePath,
    this.emoji = '🍲',
  });

  factory HotpotItem.fromJson(Map<String, dynamic> json) {
    return HotpotItem(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String? ?? '',
      targetSeconds: json['timeInSeconds'] as int,
      aliases: (json['aliases'] as List<dynamic>? ?? const [])
          .map((alias) => alias.toString())
          .toList(),
      imagePath: json['imagePath'] as String?,
      emoji: json['emoji'] as String? ?? '🍲',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'timeInSeconds': targetSeconds,
      'aliases': aliases,
      'imagePath': imagePath,
      'emoji': emoji,
    };
  }

  HotpotItem copyWith({
    String? id,
    String? name,
    String? category,
    int? targetSeconds,
    List<String>? aliases,
    String? imagePath,
    String? emoji,
  }) {
    return HotpotItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      targetSeconds: targetSeconds ?? this.targetSeconds,
      aliases: aliases ?? this.aliases,
      imagePath: imagePath ?? this.imagePath,
      emoji: emoji ?? this.emoji,
    );
  }
}
