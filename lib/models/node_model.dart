class MindMapNode {
  final String id;
  String title;
  String? parentId;
  String colorHex;
  bool isCollapsed;
  String notes;
  String type; // 'note', 'task', 'idea', 'study'
  String? dueDate;
  bool isCompleted;
  double x;
  double y;
  int strength; // 0-100
  int reviewCount;
  String? lastReviewedAt;
  int timeSpentSeconds;
  List<Map<String, String>> links; // 👈 NAYA: External Links
  List<MediaItem> media; // 👈 NAYA: Rich Media List
  int order; // 👈 NAYA: Drag & Drop Order
  List<int> routineDays; // 👈 NAYA: Routine
  List<Map<String, dynamic>> extraConnections;
  Map<String, dynamic>? interactiveData;
  String tileSize;
  String? lastCompletedDate;
  String? routineTime;
  String? coverImageUrl; // 👈 NAYA: Cover Photo ke liye

  MindMapNode({
    required this.id,
    required this.title,
    this.parentId,
    this.colorHex = '#E8D5B7',
    this.isCollapsed = false,
    this.notes = '',
    this.type = 'note',
    this.dueDate,
    this.isCompleted = false,
    this.x = 0,
    this.y = 0,
    this.strength = 0,
    this.reviewCount = 0,
    this.lastReviewedAt,
    this.timeSpentSeconds = 0,
    this.links = const [],
    this.media = const [],
    this.order = 0,
    this.routineDays = const [],
    this.tileSize = 'medium',
    this.extraConnections = const [],
    this.lastCompletedDate,
    this.routineTime,
    this.coverImageUrl, // 👈 NAYA
    this.interactiveData,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'parentId': parentId,
        'colorHex': colorHex,
        'isCollapsed': isCollapsed,
        'notes': notes,
        'type': type,
        'dueDate': dueDate,
        'isCompleted': isCompleted,
        'x': x,
        'y': y,
        'strength': strength,
        'reviewCount': reviewCount,
        'lastReviewedAt': lastReviewedAt,
        'timeSpentSeconds': timeSpentSeconds,
        'links': links,
        'media': media.map((e) => e.toJson()).toList(), // 👈 NAYA
        'order': order, // 👈 YAHAN FIX HUA
        'routineDays': routineDays,
        'tileSize': tileSize,
        'lastCompletedDate': lastCompletedDate,
        'routineTime': routineTime,
        'coverImageUrl': coverImageUrl, // 👈 NAYA
        'extraConnections': extraConnections,
        'interactiveData': interactiveData,
      };

  factory MindMapNode.fromJson(Map<String, dynamic> json) => MindMapNode(
        id: json['id'],
        title: json['title'],
        parentId: json['parentId'],
        colorHex: json['colorHex'] ?? '#E8D5B7',
        isCollapsed: json['isCollapsed'] ?? false,
        notes: json['notes'] ?? '',
        type: json['type'] ?? 'note',
        dueDate: json['dueDate'],
        isCompleted: json['isCompleted'] ?? false,
        x: (json['x'] as num?)?.toDouble() ?? 0.0,
        y: (json['y'] as num?)?.toDouble() ?? 0.0,
        strength: (json['strength'] as num?)?.toInt() ?? 0,
        reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
        lastReviewedAt: json['lastReviewedAt'],
        timeSpentSeconds: (json['timeSpentSeconds'] as num?)?.toInt() ?? 0,
        links: (json['links'] as List<dynamic>?)
                ?.map((e) => Map<String, String>.from(e))
                .toList() ??
            [],
        extraConnections: (json['extraConnections'] as List?)
                ?.map((e) => Map<String, dynamic>.from(e))
                .toList() ??
            [],
        media: (json['media'] as List<dynamic>?)
                ?.map((e) => MediaItem.fromJson(Map<String, dynamic>.from(e)))
                .toList() ??
            [], // 👈 NAYA
        order: (json['order'] as num?)?.toInt() ?? 0, // 👈 YAHAN FIX HUA
        routineDays: (json['routineDays'] as List<dynamic>?)
                ?.map((e) => e as int)
                .toList() ??
            [],
        tileSize: json['tileSize'] ?? 'medium', // 👈 NAYA
        lastCompletedDate: json['lastCompletedDate'],
        routineTime: json['routineTime'],
        coverImageUrl: json['coverImageUrl'], // 👈 NAYA
        interactiveData: json['interactiveData'] != null
            ? Map<String, dynamic>.from(json['interactiveData'])
            : null,
      );
}

class MediaItem {
  final String url; // Cloud URL or Local File Path
  final String type; // 'image', 'video', 'audio'
  final bool isLocal;

  MediaItem({
    required this.url,
    required this.type,
    this.isLocal = false,
  });

  Map<String, dynamic> toJson() => {
        'url': url,
        'type': type,
        'isLocal': isLocal,
      };

  factory MediaItem.fromJson(Map<String, dynamic> json) => MediaItem(
        url: json['url'],
        type: json['type'],
        isLocal: json['isLocal'] ?? false,
      );
}
