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
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=200',
      ],
      liveTranscript:
          '[00:12] Alex: Flutter secure storage fail-closed implementation complete.',
      aiSummary:
          'Decided to fail closed on platform secure storage errors. Decomposed WorkspaceProvider into modular controllers.',
    ),
  ];

  @override
  Future<List<CallSession>> fetchCalls() async {
    return _calls;
  }
}

class MacroCallsRepository implements CallsRepository {
  @override
  Future<List<CallSession>> fetchCalls() async {
    throw UnimplementedError('Macro API Calls endpoints not yet configured.');
  }
}
