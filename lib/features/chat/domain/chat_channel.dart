class ChatChannel {
  final String id;
  final String name;
  final String description;
  final bool isPrivate;
  final int unreadCount;
  final DateTime lastActivity;

  ChatChannel({
    required this.id,
    required this.name,
    required this.description,
    this.isPrivate = false,
    this.unreadCount = 0,
    required this.lastActivity,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'isPrivate': isPrivate,
    'unreadCount': unreadCount,
    'lastActivity': lastActivity.toIso8601String(),
  };

  factory ChatChannel.fromJson(Map<String, dynamic> json) => ChatChannel(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    isPrivate: json['isPrivate'] as bool? ?? false,
    unreadCount: json['unreadCount'] as int? ?? 0,
    lastActivity: DateTime.parse(json['lastActivity'] as String),
  );
}
