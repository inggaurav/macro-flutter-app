import 'package:macro_app/features/inbox/inbox_repository.dart';
import 'package:macro_app/models/models.dart';

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
      body:
          'Hey Alex,\n\nWe reviewed the latest MCP server deployment specs and the unified CRDT document engine.',
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
    return 'Hi Sarah, thanks for reaching out. 1) Our target WebSocket sync latency is under 45ms. 2) Yes, we persist tokens via Android Keystore and iOS Keychain!';
  }

  @override
  Future<String?> linkGmail() async {
    return 'https://auth-service.macro.com/oauth/google';
  }
}
