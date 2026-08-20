import '../../models/models.dart';

abstract interface class ChatRepository {
  Future<List<ChatChannel>> fetchChannels();
  Future<List<ChatMessage>> fetchMessages(String channelId);
  Future<ChatMessage> sendMessage(
    String channelId,
    String text,
    String senderName,
  );
}

class MockChatRepository implements ChatRepository {
  final List<ChatChannel> _channels = [
    const ChatChannel(
      id: 'c1',
      name: 'general',
      topic: 'Company-wide announcements & updates',
      unreadCount: 2,
    ),
    const ChatChannel(
      id: 'c2',
      name: 'engineering',
      topic: 'Flutter architecture, CRDT & MCP servers',
      unreadCount: 5,
    ),
    const ChatChannel(
      id: 'c3',
      name: 'sales-deals',
      topic: 'Q3 Enterprise CRM pipeline',
      unreadCount: 0,
    ),
  ];

  final List<ChatMessage> _messages = [
    ChatMessage(
      id: 'm1',
      channelId: 'c1',
      senderName: 'Alex Rivera',
      text: 'Welcome to Macro Unified Workspace!',
      timestamp: '9:00 AM',
      isAiGenerated: false,
    ),
    ChatMessage(
      id: 'm2',
      channelId: 'c2',
      senderName: 'Dev Bot',
      text: 'Build #482 passed successfully on Flutter stable channel.',
      timestamp: '9:15 AM',
      isAiGenerated: true,
    ),
    ChatMessage(
      id: 'm3',
      channelId: 'c2',
      senderName: 'Alex Rivera',
      text: 'Great! Let\'s verify secure storage on physical devices.',
      timestamp: '9:20 AM',
      isAiGenerated: false,
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
  Future<ChatMessage> sendMessage(
    String channelId,
    String text,
    String senderName,
  ) async {
    final msg = ChatMessage(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      channelId: channelId,
      senderName: senderName,
      text: text,
      timestamp:
          '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
      isAiGenerated: false,
    );
    _messages.add(msg);
    return msg;
  }
}
