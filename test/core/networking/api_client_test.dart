import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:macro_app/config/app_config.dart';
import 'package:macro_app/core/networking/api_client.dart';
import 'package:macro_app/core/storage/secure_key_value_store.dart';

class _TestTokenProvider implements AuthTokenProvider {
  String? token = 'valid_access_token';
  int refreshCount = 0;
  bool shouldRefreshSucceed = true;

  @override
  Future<String?> getAccessToken() async => token;

  @override
  Future<bool> refreshSession() async {
    refreshCount++;
    if (shouldRefreshSucceed) {
      token = 'new_refreshed_token';
      return true;
    } else {
      token = null;
      return false;
    }
  }

  @override
  Future<void> clearSession() async {
    token = null;
  }
}

void main() {
  group('ApiClient Tests', () {
    late AppConfig appConfig;
    late SecureKeyValueStore storage;

    setUp(() {
      appConfig = AppConfig.defaultConfig;
      storage = InMemorySecureStorageService();
    });

    test('200 Success GET response', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/v1/test');
        return http.Response(jsonEncode({'status': 'ok'}), 200);
      });

      final apiClient = ApiClient(
        appConfig: appConfig,
        storage: storage,
        client: mockClient,
      );
      final response = await apiClient.get('/test');

      expect(response.isSuccess, isTrue);
      expect(response.statusCode, 200);
      expect(response.data['status'], 'ok');
    });

    test('201 Success POST response', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        return http.Response(jsonEncode({'id': '123'}), 201);
      });

      final apiClient = ApiClient(
        appConfig: appConfig,
        storage: storage,
        client: mockClient,
      );
      final response = await apiClient.post(
        '/create',
        body: {'title': 'New Item'},
      );

      expect(response.isSuccess, isTrue);
      expect(response.statusCode, 201);
    });

    test('PATCH request support', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'PATCH');
        return http.Response(jsonEncode({'updated': true}), 200);
      });

      final apiClient = ApiClient(
        appConfig: appConfig,
        storage: storage,
        client: mockClient,
      );
      final response = await apiClient.patch(
        '/update',
        body: {'name': 'Updated'},
      );

      expect(response.isSuccess, isTrue);
      expect(response.data['updated'], isTrue);
    });

    test('401 Single-Flight Refresh Success & Single Retry', () async {
      final tokenProvider = _TestTokenProvider();
      int callCount = 0;

      final mockClient = MockClient((request) async {
        callCount++;
        if (request.headers['Authorization'] == 'Bearer valid_access_token') {
          return http.Response('Unauthorized', 401);
        }
        if (request.headers['Authorization'] == 'Bearer new_refreshed_token') {
          return http.Response(jsonEncode({'data': 'success'}), 200);
        }
        return http.Response('Unauthorized', 401);
      });

      final apiClient = ApiClient(
        appConfig: appConfig,
        storage: storage,
        tokenProvider: tokenProvider,
        client: mockClient,
      );

      final response = await apiClient.get('/protected');

      expect(response.isSuccess, isTrue);
      expect(response.data['data'], 'success');
      expect(tokenProvider.refreshCount, 1);
      expect(callCount, 2);
    });

    test('Concurrent 401 requests share ONE refresh call', () async {
      final tokenProvider = _TestTokenProvider();

      final mockClient = MockClient((request) async {
        if (request.headers['Authorization'] == 'Bearer valid_access_token') {
          return http.Response('Unauthorized', 401);
        }
        return http.Response(jsonEncode({'ok': true}), 200);
      });

      final apiClient = ApiClient(
        appConfig: appConfig,
        storage: storage,
        tokenProvider: tokenProvider,
        client: mockClient,
      );

      final results = await Future.wait([
        apiClient.get('/req1'),
        apiClient.get('/req2'),
        apiClient.get('/req3'),
      ]);

      expect(tokenProvider.refreshCount, 1);
      for (final res in results) {
        expect(res.isSuccess, isTrue);
      }
    });

    test(
      'Typed failures: 403 Forbidden, 404 NotFound, 422 Validation, 429 RateLimit, 500 Server',
      () async {
        final responses = [
          http.Response('Forbidden', 403),
          http.Response('Not Found', 404),
          http.Response(jsonEncode({'message': 'Invalid Email'}), 422),
          http.Response('Too many requests', 429),
          http.Response('Internal Error', 500),
        ];
        int index = 0;

        final mockClient = MockClient((_) async => responses[index++]);
        final apiClient = ApiClient(
          appConfig: appConfig,
          storage: storage,
          client: mockClient,
        );

        final f403 = await apiClient.get('/f403');
        expect(f403.failure, isA<ForbiddenFailure>());

        final f404 = await apiClient.get('/f404');
        expect(f404.failure, isA<NotFoundFailure>());

        final f422 = await apiClient.get('/f422');
        expect(f422.failure, isA<ValidationFailure>());
        expect(f422.failure?.message, 'Invalid Email');

        final f429 = await apiClient.get('/f429');
        expect(f429.failure, isA<RateLimitedFailure>());

        final f500 = await apiClient.get('/f500');
        expect(f500.failure, isA<ServerFailure>());
      },
    );
  });
}
