import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:macro_app/config/macro_service_config.dart';
import 'package:macro_app/core/auth/auth_repository.dart';
import 'package:macro_app/core/google/google_service.dart';
import 'package:macro_app/core/storage/secure_key_value_store.dart';
import 'package:macro_app/features/agents/agent_repository.dart';
import 'package:macro_app/features/chat/chat_repository.dart';
import 'package:macro_app/features/inbox/inbox_repository.dart';

void main() {
  group('Upstream Endpoint Contract Tests', () {
    final config = MacroServiceConfig.production();

    test('MacroServiceConfig Hosts are configured correctly', () {
      expect(config.authHost, equals('https://auth-service.macro.com'));
      expect(config.storageHost, equals('https://cloud-storage.macro.com'));
      expect(config.emailHost, equals('https://email-service.macro.com'));
      expect(
        config.cognitionHost,
        equals('https://document-cognition.macro.com'),
      );
      expect(
        config.connectionGateway,
        equals('wss://connection-gateway.macro.com'),
      );
    });

    test('AuthRepository fail-closed on empty storage', () async {
      final storage = InMemorySecureStorageService();
      final authRepo = AuthRepositoryImpl(storage: storage, config: config);
      final result = await authRepo.restoreSession();

      expect(result.isSuccess, isFalse);
      expect(authRepo.isAuthenticated, isFalse);
      expect(authRepo.currentUser, isNull);
    });

    test('AuthRepository fail-closed on invalid credentials', () async {
      final storage = InMemorySecureStorageService();
      final authRepo = AuthRepositoryImpl(
        storage: storage,
        config: config,
        client: MockClient((request) async {
          expect(request.method, equals('GET'));
          expect(request.url.path, equals('/user/me'));
          return http.Response('Unauthorized', 401);
        }),
      );
      final result = await authRepo.login('user@test.com', 'invalid_token');

      expect(result.isSuccess, isFalse);
      expect(authRepo.isAuthenticated, isFalse);
      expect(authRepo.currentUser, isNull);
    });

    test('AuthRepository local development signup and login works', () async {
      final storage = InMemorySecureStorageService();
      final authRepo = AuthRepositoryImpl(
        storage: storage,
        config: MacroServiceConfig.localDevelopment(),
      );

      final signupResult = await authRepo.signup(
        name: 'Macro Owner',
        email: 'owner@example.com',
        password: 'password123',
      );

      expect(signupResult, isA<AuthSuccess>());
      expect(authRepo.isAuthenticated, isTrue);
      expect(authRepo.currentUser?.email, equals('owner@example.com'));

      await authRepo.logout();
      expect(authRepo.isAuthenticated, isFalse);

      final loginResult = await authRepo.loginWithPassword(
        'owner@example.com',
        'password123',
      );

      expect(loginResult, isA<AuthSuccess>());
      expect(authRepo.isAuthenticated, isTrue);
      expect(authRepo.currentUser?.role, equals('Workspace Owner'));
    });

    test('Google SSO URI uses GET redirect contract query', () {
      final googleService = GoogleService(
        config: config,
        tokenProvider: () => null,
      );

      final uri = googleService.buildGoogleSsoUri();

      expect(uri.path, equals('/login/sso'));
      expect(uri.queryParameters['idp_name'], equals('google_gmail'));
      expect(uri.queryParameters['is_mobile'], equals('true'));
      expect(uri.queryParameters['original_url'], equals('macro://login'));
      expect(uri.queryParameters.containsKey('provider'), isFalse);
    });

    test('Session-code redemption stores access and refresh tokens', () async {
      final storage = InMemorySecureStorageService();
      final authRepo = AuthRepositoryImpl(
        storage: storage,
        config: config,
        client: MockClient((request) async {
          if (request.url.path == '/session/login/abc123') {
            expect(request.method, equals('GET'));
            return http.Response(
              jsonEncode({
                'access_token': 'access-new',
                'refresh_token': 'refresh-new',
              }),
              200,
            );
          }
          if (request.url.path == '/user/me') {
            expect(
              request.headers['Authorization'],
              equals('Bearer access-new'),
            );
            return http.Response(
              jsonEncode({
                'id': 'u1',
                'name': 'Macro Owner',
                'email': 'owner@example.com',
              }),
              200,
            );
          }
          return http.Response('Not Found', 404);
        }),
      );

      final result = await authRepo.redeemMobileSessionUri(
        Uri.parse('macro://login?token=abc123'),
      );

      expect(result, isA<AuthSuccess>());
      expect(await storage.read('auth_token'), equals('access-new'));
      expect(await storage.read('refresh_token'), equals('refresh-new'));
    });

    test('Refresh token rotation uses Macro refresh header', () async {
      final storage = InMemorySecureStorageService();
      await storage.write('auth_token', 'access-old');
      await storage.write('refresh_token', 'refresh-old');

      final authRepo = AuthRepositoryImpl(
        storage: storage,
        config: config,
        client: MockClient((request) async {
          if (request.url.path == '/jwt/refresh') {
            expect(request.method, equals('POST'));
            expect(
              request.headers['Authorization'],
              equals('Bearer access-old'),
            );
            expect(
              request.headers['x-macro-refresh-token'],
              equals('refresh-old'),
            );
            return http.Response(
              jsonEncode({
                'access_token': 'access-rotated',
                'refresh_token': 'refresh-rotated',
              }),
              200,
            );
          }
          if (request.url.path == '/user/me') {
            expect(
              request.headers['Authorization'],
              equals('Bearer access-rotated'),
            );
            return http.Response(
              jsonEncode({
                'id': 'u1',
                'name': 'Macro Owner',
                'email': 'owner@example.com',
              }),
              200,
            );
          }
          return http.Response('Not Found', 404);
        }),
      );

      final result = await authRepo.refreshSession();

      expect(result, isA<AuthSuccess>());
      expect(await storage.read('auth_token'), equals('access-rotated'));
      expect(await storage.read('refresh_token'), equals('refresh-rotated'));
    });

    test('Google account discovery parses email links', () async {
      final googleService = GoogleService(
        config: config,
        tokenProvider: () => 'access',
        client: MockClient((request) async {
          expect(request.method, equals('GET'));
          expect(request.url.path, equals('/email/links'));
          return http.Response(
            jsonEncode({
              'items': [
                {
                  'linkId': 'link-1',
                  'emailAddress': 'owner@example.com',
                  'provider': 'google',
                  'primary': true,
                  'syncActive': true,
                  'syncStatus': 'active',
                  'needsReauthentication': false,
                },
              ],
            }),
            200,
          );
        }),
      );

      final accounts = await googleService.fetchGoogleAccounts();

      expect(accounts.single.linkId, equals('link-1'));
      expect(accounts.single.emailAddress, equals('owner@example.com'));
    });

    test('Gmail status only reads reauthentication_required', () async {
      final googleService = GoogleService(
        config: config,
        tokenProvider: () => 'access',
        client: MockClient((request) async {
          expect(request.method, equals('GET'));
          expect(request.url.path, equals('/link/gmail/status'));
          return http.Response(
            jsonEncode({'reauthentication_required': true}),
            200,
          );
        }),
      );

      expect(await googleService.fetchGmailReauthenticationRequired(), isTrue);
    });

    test('Calendar list and occurrences parse required date fields', () async {
      final googleService = GoogleService(
        config: config,
        tokenProvider: () => 'access',
        client: MockClient((request) async {
          if (request.url.path == '/calendar/calendars') {
            return http.Response(
              jsonEncode({
                'items': [
                  {'id': 'cal-1', 'summary': 'Primary', 'primary': true},
                ],
              }),
              200,
            );
          }
          if (request.url.path == '/calendar-events') {
            return http.Response(
              jsonEncode({
                'items': [
                  {
                    'id': 'event-1',
                    'title': 'Standup',
                    'start_time': '2026-08-21T09:00:00Z',
                    'end_time': '2026-08-21T09:30:00Z',
                  },
                ],
              }),
              200,
            );
          }
          return http.Response('Not Found', 404);
        }),
      );

      final calendars = await googleService.fetchCalendars();
      final events = await googleService.fetchCalendarEvents();

      expect(calendars.single.id, equals('cal-1'));
      expect(events.single.id, equals('event-1'));
    });

    test('Inbox page mapping uses Macro preview cursor DTO', () async {
      final repo = MacroInboxRepository(
        config: config,
        tokenProvider: () => 'access',
        client: MockClient((request) async {
          expect(request.method, equals('GET'));
          expect(
            request.url.path,
            equals('/email/threads/previews/cursor/inbox'),
          );
          return http.Response(
            jsonEncode({
              'items': [
                {
                  'id': 'thread-1',
                  'name': 'Hello',
                  'senderName': 'Macro Sender',
                  'senderEmail': 'sender@example.com',
                  'snippet': 'Preview text',
                  'sortTs': '2026-08-21T10:00:00Z',
                  'isRead': false,
                  'linkId': 'link-1',
                },
              ],
              'next_cursor': 'cursor-2',
            }),
            200,
          );
        }),
      );

      final page = await repo.fetchInboxPage();

      expect(page.threads.single.subject, equals('Hello'));
      expect(page.threads.single.isUnread, isTrue);
      expect(page.nextCursor, equals('cursor-2'));
    });

    test('Channel and message pages parse cursor envelopes', () async {
      final repo = MacroChatRepository(
        config: config,
        tokenProvider: () => 'access',
        client: MockClient((request) async {
          if (request.url.path == '/comms/channels') {
            return http.Response(
              jsonEncode({
                'items': [
                  {
                    'id': 'channel-1',
                    'name': 'general',
                    'description': 'General',
                    'updated_at': '2026-08-21T10:00:00Z',
                  },
                ],
                'next_cursor': 'channel-cursor',
              }),
              200,
            );
          }
          if (request.url.path == '/channels/channel-1/messages') {
            return http.Response(
              jsonEncode({
                'items': [
                  {
                    'id': 'message-1',
                    'channel_id': 'channel-1',
                    'content': 'Hello',
                    'created_at': '2026-08-21T10:01:00Z',
                  },
                ],
                'next_cursor': 'next-message',
                'previous_cursor': 'prev-message',
              }),
              200,
            );
          }
          return http.Response('Not Found', 404);
        }),
      );

      final channels = await repo.fetchChannelsPage();
      final messages = await repo.fetchMessagesPage('channel-1');

      expect(channels.channels.single.id, equals('channel-1'));
      expect(channels.nextCursor, equals('channel-cursor'));
      expect(messages.messages.single.text, equals('Hello'));
      expect(messages.nextCursor, equals('next-message'));
      expect(messages.previousCursor, equals('prev-message'));
    });

    test(
      'Channel send uses singular message route and server-owned identity',
      () async {
        final repo = MacroChatRepository(
          config: config,
          tokenProvider: () => 'access',
          client: MockClient((request) async {
            expect(request.method, equals('POST'));
            expect(request.url.path, equals('/channels/channel-1/message'));
            final body = jsonDecode(request.body) as Map<String, dynamic>;
            expect(body['content'], equals('Hello'));
            expect(body.containsKey('sender_name'), isFalse);
            expect(body.containsKey('is_agent'), isFalse);
            expect(body['nonce'], isNotEmpty);
            return http.Response(
              jsonEncode({
                'id': 'message-1',
                'channel_id': 'channel-1',
                'content': 'Hello',
                'created_at': '2026-08-21T10:01:00Z',
              }),
              201,
            );
          }),
        );

        final message = await repo.sendMessage(
          channelId: 'channel-1',
          text: 'Hello',
          senderName: 'ignored',
          senderAvatar: 'ignored',
        );

        expect(message.id, equals('message-1'));
      },
    );

    test('AI request sends content and returns stream metadata', () async {
      final repo = MacroAgentRepository(
        config: config,
        tokenProvider: () => 'access',
        client: MockClient((request) async {
          expect(request.method, equals('POST'));
          expect(request.url.path, equals('/stream/chat/message'));
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['content'], equals('Summarize this'));
          expect(body.containsKey('prompt'), isFalse);
          return http.Response(
            jsonEncode({
              'stream_id': 'stream-1',
              'chat_id': 'chat-1',
              'message_id': 'message-1',
            }),
            200,
          );
        }),
      );

      final stream = await repo.startCopilotStream(content: 'Summarize this');

      expect(stream.streamId, equals('stream-1'));
      expect(stream.chatId, equals('chat-1'));
    });
  });
}
