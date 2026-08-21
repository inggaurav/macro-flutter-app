import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/macro_service_config.dart';
import '../../models/models.dart';

abstract interface class CallsRepository {
  Future<List<CallSession>> fetchCalls();
}

class MockCallsRepository implements CallsRepository {
  final List<CallSession> _calls = [
    CallSession(
      id: 'cs1',
      title: 'Weekly Engineering Sync & App Factory Architecture',
      isLive: false,
      durationMinutes: 45,
      participantAvatars: [
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
      ],
      liveTranscript:
          '[00:12] Alex: Flutter secure storage fail-closed implementation complete.',
      aiSummary: 'Decided to fail closed on platform secure storage errors.',
    ),
  ];

  @override
  Future<List<CallSession>> fetchCalls() async {
    return _calls;
  }
}

class MacroCallsRepository implements CallsRepository {
  final MacroServiceConfig _config;
  final String? Function() _tokenProvider;

  MacroCallsRepository({
    MacroServiceConfig? config,
    required this._tokenProvider,
  }) : _config = config ?? MacroServiceConfig.production();

  @override
  Future<List<CallSession>> fetchCalls() async {
    final token = _tokenProvider();
    if (token == null || token.isEmpty) return [];

    try {
      // Verified Upstream Route: GET storageHost/calls
      final response = await http
          .get(
            Uri.parse('${_config.storageHost}/calls'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((item) => CallSession.fromJson(item)).toList();
      }
    } catch (_) {}

    return [];
  }
}
