class ChatMessage {
  final String id;
  final String channelId;
  final String senderName;
  final String senderAvatar;
  final String text;
  final DateTime timestamp;
  final bool isAgent;
  final List<String> mentions;
  final String? codeSnippet;

  ChatMessage({
    required this.id,
    required this.channelId,
    required this.senderName,
    required this.senderAvatar,
    required this.text,
    required this.timestamp,
    this.isAgent = false,
    this.mentions = const [],
    this.codeSnippet,
  });
}
