import '../../models/models.dart';

abstract interface class ChatRepository {
  Future<List<ChatChannel>> fetchChannels();
  Future<List<ChatMessage>> fetchMessages(String channelId);
  Future<ChatMessage> sendMessage({
    required String channelId,
    required String text,
    required String senderName,
    required String senderAvatar,
    bool isAgent = false,
  });
}

class MockChatRepository implements ChatRepository {
  final List<ChatChannel> _channels = [
    ChatChannel(
      id: 'c1',
      name: 'general',
      description: 'Company-wide announcements & updates',
      isPrivate: false,
      unreadCount: 2,
      lastActivity: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    ChatChannel(
      id: 'c2',
      name: 'engineering',
      description: 'Flutter architecture, CRDT & MCP servers',
      isPrivate: false,
      unreadCount: 5,
      lastActivity: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    ChatChannel(
      id: 'c3',
      name: 'sales-deals',
      description: 'Q3 Enterprise CRM pipeline',
      isPrivate: true,
      unreadCount: 0,
      lastActivity: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  final List<ChatMessage> _messages = [
    ChatMessage(
      id: 'm1',
      channelId: 'c1',
      senderName: 'Alex Rivera',
      senderAvatar:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
      text: 'Welcome to Macro Unified Workspace!',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      isAgent: false,
    ),
    ChatMessage(
      id: 'm2',
      channelId: 'c2',
      senderName: 'Dev Agent',
      senderAvatar:
          'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&q=80&w=200',
      text: 'Build #482 passed successfully on Flutter stable channel.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      isAgent: true,
    ),
    ChatMessage(
      id: 'm3',
      channelId: 'c2',
      senderName: 'Alex Rivera',
      senderAvatar:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
      text: 'Great! Let\'s verify secure storage on physical devices.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      isAgent: false,
    ),
  ];

  @override
  Future<List<ChatChannel>> fetchChannels() async {
    return _channels;
  }

  @override
  Future<List<ChatMessage>> fetchMessages(String channelId) async {
    return _messages.where((m) => m.channelId == channelId).toList();
  }

  @override
  Future<ChatMessage> sendMessage({
    required String channelId,
    required String text,
    required String senderName,
    required String senderAvatar,
    bool isAgent = false,
  }) async {
    final msg = ChatMessage(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      channelId: channelId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      text: text,
      timestamp: DateTime.now(),
      isAgent: isAgent,
    );
    _messages.add(msg);
    return msg;
  }
}

class MacroChatRepository implements ChatRepository {
  @override
  Future<List<ChatChannel>> fetchChannels() async {
    throw UnimplementedError('Macro API Chat endpoints not yet configured.');
  }

  @override
  Future<List<ChatMessage>> fetchMessages(String channelId) async {
    throw UnimplementedError('Macro API Chat endpoints not yet configured.');
  }

  @override
  Future<ChatMessage> sendMessage({
    required String channelId,
    required String text,
    required String senderName,
    required String senderAvatar,
    bool isAgent = false,
  }) async {
    throw UnimplementedError('Macro API Chat endpoints not yet configured.');
  }
}
