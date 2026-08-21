import 'package:macro_app/features/chat/chat_repository.dart';
import 'package:macro_app/models/models.dart';

class MockChatRepository implements ChatRepository {
  final List<ChatChannel> _channels = [
    ChatChannel(
      id: 'c1',
      name: 'general',
      description: 'Company-wide announcements & updates',
      isPrivate: false,
      unreadCount: 0,
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
      senderName: 'Gaurav',
      senderAvatar: '',
      text: 'Welcome to Macro Chat',
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    ChatMessage(
      id: 'm2',
      channelId: 'c2',
      senderName: 'Dev Agent',
      senderAvatar: '',
      text: 'Build passed.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      isAgent: true,
    ),
    ChatMessage(
      id: 'm3',
      channelId: 'c2',
      senderName: 'Alex Rivera',
      senderAvatar: '',
      text: 'Great job!',
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
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
