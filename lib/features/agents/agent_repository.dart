import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/macro_service_config.dart';
import '../../models/models.dart';

abstract interface class AgentRepository {
  Future<List<AiMemoryItem>> fetchMemories();
  Future<String> queryCopilot(String prompt);
}

class MockAgentRepository implements AgentRepository {
  final List<AiMemoryItem> _memories = [
    AiMemoryItem(
      id: 'm1',
      category: 'team_context',
      title: 'WebSocket Latency SLA',
      summary:
          'Multi-region real-time sync target is established at <45ms across edge nodes.',
      source: 'Slack #engineering',
      confidence: 0.98,
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  @override
  Future<List<AiMemoryItem>> fetchMemories() async {
    return _memories;
  }

  @override
  Future<String> queryCopilot(String prompt) async {
    return 'Based on team context: We use FlutterSecureStorage backed by Android Keystore / iOS Keychain.';
  }
}

class MacroAgentRepository implements AgentRepository {
  final MacroServiceConfig _config;
  final String? Function() _tokenProvider;

  MacroAgentRepository({
    MacroServiceConfig? config,
    required this._tokenProvider,
  }) : _config = config ?? MacroServiceConfig.production();

  @override
  Future<List<AiMemoryItem>> fetchMemories() async {
    final token = _tokenProvider();
    if (token == null || token.isEmpty) return [];

    try {
      // Verified Upstream Route: GET cognitionHost/memory
      final response = await http
          .get(
            Uri.parse('${_config.cognitionHost}/memory'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((item) => AiMemoryItem.fromJson(item)).toList();
      }
    } catch (_) {}

    return [];
  }

  @override
  Future<String> queryCopilot(String prompt) async {
    final token = _tokenProvider();
    if (token == null || token.isEmpty) {
      throw Exception(
        'Unauthenticated: Cannot query AI without active session token',
      );
    }

    try {
      // Verified Upstream Route: POST cognitionHost/stream/chat/message
      final response = await http
          .post(
            Uri.parse('${_config.cognitionHost}/stream/chat/message'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'prompt': prompt}),
          )
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['text'] ??
            data['response'] ??
            data['stream_id'] ??
            'Query processed.';
      } else {
        throw Exception('HTTP ${response.statusCode} from cognition service');
      }
    } catch (e) {
      throw Exception('AI Cognition service unavailable: $e');
    }
  }
}
