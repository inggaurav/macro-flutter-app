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

  Map<String, dynamic> toJson() => {
    'id': id,
    'channelId': channelId,
    'senderName': senderName,
    'senderAvatar': senderAvatar,
    'text': text,
    'timestamp': timestamp.toIso8601String(),
    'isAgent': isAgent,
    'mentions': mentions,
    'codeSnippet': codeSnippet,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'] as String,
    channelId: json['channelId'] as String,
    senderName: json['senderName'] as String,
    senderAvatar: json['senderAvatar'] as String,
    text: json['text'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    isAgent: json['isAgent'] as bool? ?? false,
    mentions:
        (json['mentions'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [],
    codeSnippet: json['codeSnippet'] as String?,
  );
}
