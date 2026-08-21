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
    AiMemoryItem(
      id: 'm2',
      category: 'tech_stack',
      title: 'Session Token Persistence Invariant',
      summary:
          'Tokens must be stored in Android Keystore / iOS Keychain via FlutterSecureStorage.',
      source: 'CRDT Document #d1',
      confidence: 0.99,
      updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
  ];

  @override
  Future<List<AiMemoryItem>> fetchMemories() async {
    return _memories;
  }

  @override
  Future<String> queryCopilot(String prompt) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return 'Based on team context: We use FlutterSecureStorage backed by Android Keystore / iOS Keychain. Target sync latency is <45ms.';
  }
}

class MacroAgentRepository implements AgentRepository {
  @override
  Future<List<AiMemoryItem>> fetchMemories() async {
    throw UnimplementedError('Macro API Agent endpoints not yet configured.');
  }

  @override
  Future<String> queryCopilot(String prompt) async {
    throw UnimplementedError('Macro API Agent endpoints not yet configured.');
  }
}
