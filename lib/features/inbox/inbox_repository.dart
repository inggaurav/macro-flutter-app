import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/macro_service_config.dart';
import '../../core/networking/macro_api_exception.dart';
import '../../models/models.dart';

abstract interface class InboxRepository {
  Future<List<EmailThread>> fetchEmails();
  Future<void> markAsRead(String id);
  Future<String> generateAiReply(String emailId);
  Future<String?> linkGmail();
}

class MockInboxRepository implements InboxRepository {
  final List<EmailThread> _emails = [
    EmailThread(
      id: 'e1',
      senderName: 'Sarah Jenkins',
      senderEmail: 'sarah@vortex.io',
      subject: 'Series A Term Sheet Review & MCP Agent Deployment',
      preview:
          'Hey Alex, we reviewed the latest MCP server deployment specs...',
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 18)),
      body: '''Hey Alex,

We reviewed the latest MCP server deployment specs and the unified CRDT document engine. Overall the team is very impressed with how responsive the Flutter client is.

A few questions before we sign off on the term sheet:
1. What is our target latency for multi-region WebSocket sync?
2. Are we using Android Keystore/Keychain for offline session tokens?

Let us know when you can jump on a quick call.

Best,
Sarah''',
      isUnread: true,
      tags: ['Investment', 'High Priority'],
    ),
    EmailThread(
      id: 'e2',
      senderName: 'GitHub Actions CI',
      senderEmail: 'notifications@github.com',
      subject: 'Build #482 Passed: Flutter Stable Release Candidate',
      preview:
          'Workflow "Flutter App CI Pipeline" completed successfully on main branch.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      body:
          'All 42 widget & unit tests passed. Debug APK generated successfully.',
      isUnread: false,
      tags: ['DevOps', 'CI/CD'],
    ),
  ];

  @override
  Future<List<EmailThread>> fetchEmails() async => _emails;

  @override
  Future<void> markAsRead(String id) async {
    final idx = _emails.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final old = _emails[idx];
      _emails[idx] = EmailThread(
        id: old.id,
        senderName: old.senderName,
        senderEmail: old.senderEmail,
        subject: old.subject,
        preview: old.preview,
        timestamp: old.timestamp,
        body: old.body,
        isUnread: false,
        tags: old.tags,
      );
    }
  }

  @override
  Future<String> generateAiReply(String emailId) async {
    return 'Hi Sarah, thanks for reaching out. Our target WebSocket sync latency is under 45ms, and we persist tokens via secure platform storage.';
  }

  @override
  Future<String?> linkGmail() async {
    return 'https://auth-service.macro.com/login/sso?idp_name=google_gmail&is_mobile=true&original_url=macro%3A%2F%2Flogin';
  }
}

class MacroInboxPage {
  final List<EmailThread> threads;
  final String? nextCursor;

  const MacroInboxPage({required this.threads, this.nextCursor});
}

class MacroEmailMapper {
  static MacroInboxPage pageFromJson(Map<String, dynamic> json) {
    final items = json['items'];
    if (items is! List) {
      throw const FormatException('Inbox page missing items array.');
    }
    return MacroInboxPage(
      threads: items.map((item) => previewFromJson(item)).toList(),
      nextCursor: json['next_cursor']?.toString(),
    );
  }

  static EmailThread previewFromJson(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      throw const FormatException('Inbox preview item is not an object.');
    }

    final id = raw['id'];
    final senderEmail = raw['senderEmail'] ?? raw['sender_email'];
    final senderName = raw['senderName'] ?? raw['sender_name'];
    final sortTs = raw['sortTs'] ?? raw['sort_ts'] ?? raw['timestamp'];
    if (id == null ||
        senderEmail == null ||
        senderName == null ||
        sortTs == null) {
      throw const FormatException('Inbox preview required fields missing.');
    }

    final timestamp = DateTime.tryParse(sortTs.toString());
    if (timestamp == null) {
      throw const FormatException('Inbox preview timestamp malformed.');
    }

    final labels = raw['labels'] is List
        ? (raw['labels'] as List).map((item) => item.toString()).toList()
        : <String>[];
    final attachments = raw['attachments'] is List
        ? (raw['attachments'] as List).map((item) => item.toString()).toList()
        : <String>[];

    return EmailThread(
      id: id.toString(),
      senderName: senderName.toString(),
      senderEmail: senderEmail.toString(),
      subject:
          raw['name']?.toString() ??
          raw['subject']?.toString() ??
          '(No subject)',
      preview: raw['snippet']?.toString() ?? raw['preview']?.toString() ?? '',
      body: '',
      timestamp: timestamp,
      isUnread: raw['isRead'] == false || raw['is_read'] == false,
      isStarred: raw['starred'] == true || raw['isStarred'] == true,
      tags: [...labels, if (attachments.isNotEmpty) 'Attachments'],
      linkedCompanyName: raw['linkedCompanyName']?.toString(),
    );
  }
}

class MacroInboxRepository implements InboxRepository {
  final MacroServiceConfig _config;
  final String? Function() _tokenProvider;
  final http.Client _client;
  String? _nextCursor;

  MacroInboxRepository({
    MacroServiceConfig? config,
    required this._tokenProvider,
    http.Client? client,
  }) : _config = config ?? MacroServiceConfig.production(),
       _client = client ?? http.Client();

  String? get nextCursor => _nextCursor;

  @override
  Future<List<EmailThread>> fetchEmails() async {
    final page = await fetchInboxPage();
    return page.threads;
  }

  Future<MacroInboxPage> fetchInboxPage({String? cursor}) async {
    final token = _requireToken();
    final uri =
        Uri.parse(
          '${_config.emailHost}/email/threads/previews/cursor/inbox',
        ).replace(
          queryParameters: {
            'limit': '25',
            if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
          },
        );

    final response = await _client
        .get(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 4));

    if (response.statusCode != 200) {
      throw MacroApiException(
        'Failed to load inbox thread previews.',
        statusCode: response.statusCode,
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final page = MacroEmailMapper.pageFromJson(data);
    _nextCursor = page.nextCursor;
    return page;
  }

  @override
  Future<void> markAsRead(String id) async {
    final token = _requireToken();
    final response = await _client
        .post(
          Uri.parse('${_config.emailHost}/email/threads/$id/seen'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 3));

    if (response.statusCode >= 400) {
      throw MacroApiException(
        'Failed to mark thread as read.',
        statusCode: response.statusCode,
      );
    }
  }

  @override
  Future<String> generateAiReply(String emailId) async {
    final token = _requireToken();
    final response = await _client
        .post(
          Uri.parse('${_config.cognitionHost}/email/reply-draft'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({'email_id': emailId}),
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw MacroApiException(
        'Draft generation failed.',
        statusCode: response.statusCode,
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['reply_draft']?.toString() ??
        data['text']?.toString() ??
        data['content']?.toString() ??
        'Draft generated.';
  }

  @override
  Future<String?> linkGmail() async {
    final token = _requireToken();
    final uri = Uri.parse('${_config.authHost}/link/gmail').replace(
      queryParameters: {
        'scopes': 'gmail_and_calendar',
        'original_url': 'macro://login',
      },
    );
    final response = await _client
        .post(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 4));

    if (response.statusCode != 200) {
      throw MacroApiException(
        'Failed to create Gmail authorization link.',
        statusCode: response.statusCode,
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['authorization_url']?.toString() ?? data['url']?.toString();
  }

  String _requireToken() {
    final token = _tokenProvider();
    if (token == null || token.isEmpty) {
      throw const MacroApiException('No active session token.');
    }
    return token;
  }
}
