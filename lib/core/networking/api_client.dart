import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import '../storage/secure_key_value_store.dart';

sealed class ApiFailure {
  final String message;
  final int? statusCode;
  const ApiFailure(this.message, [this.statusCode]);
}

class NetworkFailure extends ApiFailure {
  const NetworkFailure([
    super.message = 'Network connectivity failure.',
    super.statusCode,
  ]);
}

class TimeoutFailure extends ApiFailure {
  const TimeoutFailure([
    super.message = 'Request timed out.',
    super.statusCode,
  ]);
}

class UnauthorizedFailure extends ApiFailure {
  const UnauthorizedFailure([
    super.message = 'Authentication token invalid or expired.',
    super.statusCode = 401,
  ]);
}

class ForbiddenFailure extends ApiFailure {
  const ForbiddenFailure([
    super.message = 'Access forbidden.',
    super.statusCode = 403,
  ]);
}

class NotFoundFailure extends ApiFailure {
  const NotFoundFailure([
    super.message = 'Resource not found.',
    super.statusCode = 404,
  ]);
}

class ValidationFailure extends ApiFailure {
  const ValidationFailure([
    super.message = 'Invalid request data.',
    super.statusCode = 422,
  ]);
}

class RateLimitedFailure extends ApiFailure {
  const RateLimitedFailure([
    super.message = 'Rate limit exceeded.',
    super.statusCode = 429,
  ]);
}

class ServerFailure extends ApiFailure {
  const ServerFailure([
    super.message = 'Internal server error.',
    super.statusCode = 500,
  ]);
}

class SerializationFailure extends ApiFailure {
  const SerializationFailure([
    super.message = 'Failed to parse server response.',
    super.statusCode,
  ]);
}

class UnknownFailure extends ApiFailure {
  const UnknownFailure([
    super.message = 'An unknown error occurred.',
    super.statusCode,
  ]);
}

class ApiResponse<T> {
  final T? data;
  final ApiFailure? failure;
  final int statusCode;

  const ApiResponse.success(this.data, {this.statusCode = 200})
    : failure = null;
  const ApiResponse.failure(this.failure, {this.statusCode = 500})
    : data = null;

  bool get isSuccess => failure == null;
}

class ApiClient {
  final AppConfig appConfig;
  final SecureKeyValueStore storage;
  final http.Client client;
  final Duration timeout;

  ApiClient({
    required this.appConfig,
    required this.storage,
    http.Client? client,
    this.timeout = const Duration(seconds: 15),
  }) : client = client ?? http.Client();

  Future<Map<String, String>> _buildHeaders() async {
    final token = await storage.read('auth_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<ApiResponse<dynamic>> get(
    String path, {
    Map<String, String>? queryParams,
  }) async {
    final uri = Uri.parse(
      '${appConfig.apiBaseUrl}$path',
    ).replace(queryParameters: queryParams);
    return _request(() async {
      final headers = await _buildHeaders();
      return await client.get(uri, headers: headers).timeout(timeout);
    });
  }

  Future<ApiResponse<dynamic>> post(String path, {dynamic body}) async {
    final uri = Uri.parse('${appConfig.apiBaseUrl}$path');
    return _request(() async {
      final headers = await _buildHeaders();
      return await client
          .post(uri, headers: headers, body: jsonEncode(body))
          .timeout(timeout);
    });
  }

  Future<ApiResponse<dynamic>> put(String path, {dynamic body}) async {
    final uri = Uri.parse('${appConfig.apiBaseUrl}$path');
    return _request(() async {
      final headers = await _buildHeaders();
      return await client
          .put(uri, headers: headers, body: jsonEncode(body))
          .timeout(timeout);
    });
  }

  Future<ApiResponse<dynamic>> delete(String path) async {
    final uri = Uri.parse('${appConfig.apiBaseUrl}$path');
    return _request(() async {
      final headers = await _buildHeaders();
      return await client.delete(uri, headers: headers).timeout(timeout);
    });
  }

  Future<ApiResponse<dynamic>> _request(
    Future<http.Response> Function() call,
  ) async {
    try {
      final response = await call();
      return _parseResponse(response);
    } on TimeoutException {
      return const ApiResponse.failure(TimeoutFailure(), statusCode: 408);
    } catch (e) {
      if (kDebugMode) debugPrint('ApiClient Network Exception: $e');
      return ApiResponse.failure(NetworkFailure(e.toString()), statusCode: 0);
    }
  }

  ApiResponse<dynamic> _parseResponse(http.Response response) {
    dynamic decoded;
    if (response.body.isNotEmpty) {
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        return ApiResponse.failure(
          const SerializationFailure(),
          statusCode: response.statusCode,
        );
      }
    }

    switch (response.statusCode) {
      case 200:
      case 201:
      case 204:
        return ApiResponse.success(decoded, statusCode: response.statusCode);
      case 401:
        return ApiResponse.failure(
          const UnauthorizedFailure(),
          statusCode: 401,
        );
      case 403:
        return ApiResponse.failure(const ForbiddenFailure(), statusCode: 403);
      case 404:
        return ApiResponse.failure(const NotFoundFailure(), statusCode: 404);
      case 422:
        return ApiResponse.failure(
          ValidationFailure(decoded?['message'] ?? 'Validation error'),
          statusCode: 422,
        );
      case 429:
        return ApiResponse.failure(const RateLimitedFailure(), statusCode: 429);
      default:
        if (response.statusCode >= 500) {
          return ApiResponse.failure(
            ServerFailure(decoded?['message'] ?? 'Server error'),
            statusCode: response.statusCode,
          );
        }
        return ApiResponse.failure(
          UnknownFailure(decoded?['message'] ?? 'Error occurred'),
          statusCode: response.statusCode,
        );
    }
  }
}
