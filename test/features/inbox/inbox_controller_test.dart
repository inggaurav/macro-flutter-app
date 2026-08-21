import 'package:flutter_test/flutter_test.dart';
import 'package:macro_app/core/persistence/local_cache.dart';
import 'package:macro_app/features/inbox/controllers/inbox_controller.dart';
import '../../fixtures/mock_inbox_repository.dart';

void main() {
  group('InboxController Unit Tests', () {
    late MockInboxRepository repository;
    late InMemoryLocalCacheStore cacheStore;
    late InboxController controller;

    setUp(() {
      repository = MockInboxRepository();
      cacheStore = InMemoryLocalCacheStore();
      controller = InboxController(
        repository: repository,
        cacheStore: cacheStore,
      );
    });

    tearDown(() {
      controller.dispose();
    });

    test(
      'loadEmails populates threads, selects first thread & caches data',
      () async {
        await controller.loadEmails();

        expect(controller.emails.length, 2);
        expect(controller.selectedEmail, isNotNull);
        expect(
          controller.selectedEmail!.subject,
          contains('Series A Term Sheet'),
        );

        // Verify thread caching
        final cached = await cacheStore.get('workspace:default:inbox:threads');
        expect(cached, isA<List>());
        expect((cached as List).length, 2);
      },
    );

    test('selectEmail updates selection & marks thread as read', () async {
      await controller.loadEmails();
      expect(controller.emails.first.isUnread, isTrue);

      controller.selectEmail('e1');

      expect(controller.selectedEmail!.id, 'e1');
      expect(controller.emails.first.isUnread, isFalse);
    });

    test('generateAiReply populates generatedReplyDraft', () async {
      await controller.loadEmails();
      await controller.generateAiReply('e1');

      expect(controller.generatedReplyDraft, isNotNull);
      expect(
        controller.generatedReplyDraft,
        contains('target WebSocket sync latency'),
      );
    });
  });
}
