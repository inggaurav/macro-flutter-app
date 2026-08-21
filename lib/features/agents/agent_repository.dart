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
    return 'Based on team context: We use FlutterSecureStorage backed by Android Keystore / iOS Keychain. Target sync latency is <45ms.';
  }
}

class MacroAgentRepository implements AgentRepository {
  final MacroServiceConfig _config;
  final String? Function() _tokenProvider;

  MacroAgentRepository({
    MacroServiceConfig? config,
    required String? Function() tokenProvider,
  }) : _config = config ?? MacroServiceConfig.production(),
       _tokenProvider = tokenProvider;

  @override
  Future<List<AiMemoryItem>> fetchMemories() async {
    final token = _tokenProvider();
    if (token == null || token.isEmpty) return [];

    try {
      final response = await http
          .get(
            Uri.parse('${_config.cognitionHost}/v1/memory'),
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
    if (token == null || token.isEmpty) return 'No active Macro session token.';

    try {
      final response = await http
          .post(
            Uri.parse('${_config.cognitionHost}/v1/chat'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'prompt': prompt}),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['text'] ?? data['response'] ?? 'Query processed.';
      }
    } catch (_) {}

    return 'AI Cognition service offline or unavailable.';
  }
}
