import 'package:flutter_test/flutter_test.dart';
import 'package:macro_app/core/persistence/local_cache.dart';
import 'package:macro_app/core/realtime/realtime_client.dart';
import 'package:macro_app/features/chat/chat_repository.dart';
import 'package:macro_app/features/chat/controllers/chat_controller.dart';
import 'package:macro_app/features/chat/domain/chat_message.dart';

void main() {
  group('ChatController Unit Tests', () {
    late MockChatRepository repository;
    late InMemoryLocalCacheStore cacheStore;
    late MockRealtimeClient realtimeClient;
    late ChatController controller;

    setUp(() {
      repository = MockChatRepository();
      cacheStore = InMemoryLocalCacheStore();
      realtimeClient = MockRealtimeClient();
      controller = ChatController(
        repository: repository,
        cacheStore: cacheStore,
        realtimeClient: realtimeClient,
      );
    });

    tearDown(() {
      controller.dispose();
    });

    test(
      'loadChannels populates channels, selects active channel & caches data',
      () async {
        await controller.loadChannels();

        expect(controller.channels.length, 3);
        expect(controller.activeChannel, isNotNull);
        expect(controller.activeChannel!.name, 'general');

        // Verify channel caching
        final cached = await cacheStore.get('workspace:default:chat:channels');
        expect(cached, isA<List>());
        expect((cached as List).length, 3);
      },
    );

    test(
      'selectChannel switches active channel & loads channel messages',
      () async {
        await controller.loadChannels();
        await controller.selectChannel('c2');

        expect(controller.activeChannel!.id, 'c2');
        expect(controller.activeChannel!.name, 'engineering');
        expect(controller.activeMessages.length, 2);
      },
    );

    test(
      'sendMessage appends message, updates cache & emits realtime event',
      () async {
        await controller.loadChannels();
        await controller.selectChannel('c1');

        final countBefore = controller.activeMessages.length;

        await controller.sendMessage(
          text: 'Unit test message',
          senderName: 'Tester',
          senderAvatar: 'https://example.com/avatar.jpg',
        );

        expect(controller.activeMessages.length, countBefore + 1);
        expect(controller.activeMessages.last.text, 'Unit test message');
      },
    );

    test(
      'Realtime message for active channel appends without duplicate',
      () async {
        await controller.loadChannels();
        await controller.selectChannel('c1');

        final incoming = ChatMessage(
          id: 'rt_msg_999',
          channelId: 'c1',
          senderName: 'Remote User',
          senderAvatar: 'https://example.com/avatar.jpg',
          text: 'Incoming Realtime Event',
          timestamp: DateTime.now(),
        );

        realtimeClient.sendEvent(
          RealtimeEvent(
            type: 'chat_message_created',
            payload: incoming.toJson(),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 100));

        expect(
          controller.activeMessages.any((m) => m.id == 'rt_msg_999'),
          isTrue,
        );
      },
    );
  });
}
