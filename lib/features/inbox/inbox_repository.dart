import '../../models/models.dart';

abstract interface class InboxRepository {
  Future<List<EmailThread>> fetchEmails();
  Future<void> markAsRead(String id);
  Future<String> generateAiReply(String emailId);
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
  Future<List<EmailThread>> fetchEmails() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _emails;
  }

  @override
  Future<void> markAsRead(String id) async {
    final idx = _emails.indexWhere((e) => e.id == id);
    if (idx != -1) {
      _emails[idx] = EmailThread(
        id: _emails[idx].id,
        senderName: _emails[idx].senderName,
        senderEmail: _emails[idx].senderEmail,
        subject: _emails[idx].subject,
        preview: _emails[idx].preview,
        timestamp: _emails[idx].timestamp,
        body: _emails[idx].body,
        isUnread: false,
        tags: _emails[idx].tags,
      );
    }
  }

  @override
  Future<String> generateAiReply(String emailId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return 'Hi Sarah, thanks for reaching out. 1) Our target WebSocket sync latency is under 45ms. 2) Yes, we persist tokens via Android Keystore and iOS Keychain!';
  }
}

class MacroInboxRepository implements InboxRepository {
  @override
  Future<List<EmailThread>> fetchEmails() async {
    throw UnimplementedError('Macro API Inbox endpoints not yet configured.');
  }

  @override
  Future<void> markAsRead(String id) async {
    throw UnimplementedError('Macro API Inbox endpoints not yet configured.');
  }

  @override
  Future<String> generateAiReply(String emailId) async {
    throw UnimplementedError('Macro API Inbox endpoints not yet configured.');
  }
}
