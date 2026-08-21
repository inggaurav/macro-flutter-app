class EmailThread {
  final String id;
  final String subject;
  final String senderName;
  final String senderEmail;
  final String preview;
  final String body;
  final DateTime timestamp;
  final bool isUnread;
  final bool isStarred;
  final List<String> tags;
  final String? linkedCompanyName;

  EmailThread({
    required this.id,
    required this.subject,
    required this.senderName,
    required this.senderEmail,
    required this.preview,
    required this.body,
    required this.timestamp,
    this.isUnread = false,
    this.isStarred = false,
    required this.tags,
    this.linkedCompanyName,
  });
}
