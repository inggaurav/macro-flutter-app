import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/macro_service_config.dart';
import '../../core/networking/macro_api_exception.dart';
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
  Future<List<AiMemoryItem>> fetchMemories() async => _memories;

  @override
  Future<String> queryCopilot(String prompt) async {
    return 'Based on team context: We use FlutterSecureStorage backed by Android Keystore / iOS Keychain.';
  }
}

class MacroAiStreamStart {
  final String streamId;
  final String? chatId;
  final String? messageId;

  const MacroAiStreamStart({
    required this.streamId,
    this.chatId,
    this.messageId,
  });

  factory MacroAiStreamStart.fromJson(Map<String, dynamic> json) {
    final streamId = json['stream_id'] ?? json['streamId'];
    if (streamId == null || streamId.toString().isEmpty) {
      throw const FormatException('AI stream response missing stream_id.');
    }
    return MacroAiStreamStart(
      streamId: streamId.toString(),
      chatId: json['chat_id']?.toString() ?? json['chatId']?.toString(),
      messageId:
          json['message_id']?.toString() ?? json['messageId']?.toString(),
    );
  }
}

class MacroAgentRepository implements AgentRepository {
  final MacroServiceConfig _config;
  final String? Function() _tokenProvider;
  final http.Client _client;

  MacroAgentRepository({
    MacroServiceConfig? config,
    required this._tokenProvider,
    http.Client? client,
  }) : _config = config ?? MacroServiceConfig.production(),
       _client = client ?? http.Client();

  @override
  Future<List<AiMemoryItem>> fetchMemories() async {
    final token = _requireToken();
    final response = await _client
        .get(
          Uri.parse('${_config.cognitionHost}/memory'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 4));

    if (response.statusCode != 200) {
      throw MacroApiException(
        'Failed to load AI memory.',
        statusCode: response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body);
    final List items = decoded is Map<String, dynamic>
        ? decoded['items'] as List? ?? decoded['memories'] as List? ?? []
        : decoded as List;
    return items.map((item) => AiMemoryItem.fromJson(item)).toList();
  }

  @override
  Future<String> queryCopilot(String prompt) async {
    final stream = await startCopilotStream(content: prompt);
    return 'AI stream started: stream=${stream.streamId} chat=${stream.chatId ?? "new"} message=${stream.messageId ?? "pending"}';
  }

  Future<MacroAiStreamStart> startCopilotStream({
    required String content,
    String? chatId,
    List<Object> attachments = const [],
  }) async {
    final token = _requireToken();
    final response = await _client
        .post(
          Uri.parse('${_config.cognitionHost}/stream/chat/message'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'content': content,
            if (chatId != null && chatId.isNotEmpty) 'chat_id': chatId,
            'attachments': attachments,
          }),
        )
        .timeout(const Duration(seconds: 6));

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw MacroApiException(
        'Cognition service rejected AI message.',
        statusCode: response.statusCode,
      );
    }

    return MacroAiStreamStart.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  String _requireToken() {
    final token = _tokenProvider();
    if (token == null || token.isEmpty) {
      throw const MacroApiException('No active session token.');
    }
    return token;
  }
}
