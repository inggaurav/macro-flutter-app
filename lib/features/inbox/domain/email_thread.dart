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

  Map<String, dynamic> toJson() => {
    'id': id,
    'subject': subject,
    'senderName': senderName,
    'senderEmail': senderEmail,
    'preview': preview,
    'body': body,
    'timestamp': timestamp.toIso8601String(),
    'isUnread': isUnread,
    'isStarred': isStarred,
    'tags': tags,
    'linkedCompanyName': linkedCompanyName,
  };

  factory EmailThread.fromJson(Map<String, dynamic> json) => EmailThread(
    id: json['id'] as String,
    subject: json['subject'] as String,
    senderName: json['senderName'] as String,
    senderEmail: json['senderEmail'] as String,
    preview: json['preview'] as String,
    body: json['body'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    isUnread: json['isUnread'] as bool? ?? false,
    isStarred: json['isStarred'] as bool? ?? false,
    tags:
        (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        [],
    linkedCompanyName: json['linkedCompanyName'] as String?,
  );

  factory EmailThread.fromUpstreamJson(
    Map<String, dynamic> json,
  ) => EmailThread(
    id: json['id']?.toString() ?? '',
    subject: json['subject']?.toString() ?? '(No Subject)',
    senderName:
        json['sender_name']?.toString() ??
        json['senderName']?.toString() ??
        'Sender',
    senderEmail:
        json['sender_email']?.toString() ??
        json['senderEmail']?.toString() ??
        '',
    preview: json['snippet']?.toString() ?? json['preview']?.toString() ?? '',
    body:
        (json['messages'] as List?)?.first?['content']?.toString() ??
        json['body']?.toString() ??
        json['snippet']?.toString() ??
        '',
    timestamp:
        DateTime.tryParse(
          json['updated_at']?.toString() ?? json['timestamp']?.toString() ?? '',
        ) ??
        DateTime.now(),
    isUnread: json['is_unread'] == true || json['isUnread'] == true,
    isStarred: json['is_starred'] == true || json['isStarred'] == true,
    tags:
        (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        ['Inbox'],
    linkedCompanyName:
        json['linked_company']?.toString() ??
        json['linkedCompanyName']?.toString(),
  );
}
