import 'package:flutter_test/flutter_test.dart';
import 'package:macro_app/features/inbox/domain/email_thread.dart';
import 'package:macro_app/features/chat/domain/chat_channel.dart';
import 'package:macro_app/features/chat/domain/chat_message.dart';

void main() {
  group('Model Serialization Tests', () {
    test('EmailThread toJson & fromJson roundtrip', () {
      final now = DateTime.now();
      final thread = EmailThread(
        id: 'e1',
        subject: 'Test Subject',
        senderName: 'Alex Rivera',
        senderEmail: 'alex@macro.app',
        preview: 'Test Preview',
        body: 'Test Body',
        timestamp: now,
        isUnread: true,
        isStarred: true,
        tags: ['Dev', 'Test'],
        linkedCompanyName: 'Macro Inc',
      );

      final json = thread.toJson();
      final restored = EmailThread.fromJson(json);

      expect(restored.id, thread.id);
      expect(restored.subject, thread.subject);
      expect(restored.senderName, thread.senderName);
      expect(restored.senderEmail, thread.senderEmail);
      expect(restored.preview, thread.preview);
      expect(restored.body, thread.body);
      expect(restored.isUnread, isTrue);
      expect(restored.isStarred, isTrue);
      expect(restored.tags, equals(['Dev', 'Test']));
      expect(restored.linkedCompanyName, 'Macro Inc');
    });

    test('ChatChannel toJson & fromJson roundtrip', () {
      final now = DateTime.now();
      final channel = ChatChannel(
        id: 'c1',
        name: 'engineering',
        description: 'Tech & Architecture',
        isPrivate: true,
        unreadCount: 4,
        lastActivity: now,
      );

      final json = channel.toJson();
      final restored = ChatChannel.fromJson(json);

      expect(restored.id, channel.id);
      expect(restored.name, channel.name);
      expect(restored.description, channel.description);
      expect(restored.isPrivate, isTrue);
      expect(restored.unreadCount, 4);
    });

    test('ChatMessage toJson & fromJson roundtrip', () {
      final now = DateTime.now();
      final message = ChatMessage(
        id: 'm1',
        channelId: 'c1',
        senderName: 'Agent Bot',
        senderAvatar: 'https://example.com/avatar.jpg',
        text: 'System notification',
        timestamp: now,
        isAgent: true,
        mentions: ['@Alex'],
        codeSnippet: 'void main() {}',
      );

      final json = message.toJson();
      final restored = ChatMessage.fromJson(json);

      expect(restored.id, message.id);
      expect(restored.channelId, message.channelId);
      expect(restored.senderName, message.senderName);
      expect(restored.isAgent, isTrue);
      expect(restored.mentions, equals(['@Alex']));
      expect(restored.codeSnippet, 'void main() {}');
    });
  });
}
