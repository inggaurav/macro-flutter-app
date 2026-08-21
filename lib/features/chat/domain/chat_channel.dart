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
}
