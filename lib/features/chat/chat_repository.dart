import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../config/macro_service_config.dart';
import '../../core/networking/macro_api_exception.dart';
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
  ];

  @override
  Future<List<ChatChannel>> fetchChannels() async => _channels;

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

class MacroChannelPage {
  final List<ChatChannel> channels;
  final String? nextCursor;

  const MacroChannelPage({required this.channels, this.nextCursor});
}

class MacroMessagePage {
  final List<ChatMessage> messages;
  final String? nextCursor;
  final String? previousCursor;

  const MacroMessagePage({
    required this.messages,
    this.nextCursor,
    this.previousCursor,
  });
}

class MacroChatMapper {
  static MacroChannelPage channelsPageFromJson(Map<String, dynamic> json) {
    final items = json['items'];
    if (items is! List) {
      throw const FormatException('Channel page missing items array.');
    }
    return MacroChannelPage(
      channels: items.map((item) => channelFromJson(item)).toList(),
      nextCursor: json['next_cursor']?.toString(),
    );
  }

  static MacroMessagePage messagesPageFromJson(
    Map<String, dynamic> json,
    String fallbackChannelId,
  ) {
    final items = json['items'];
    if (items is! List) {
      throw const FormatException('Message page missing items array.');
    }
    return MacroMessagePage(
      messages: items
          .map((item) => messageFromJson(item, fallbackChannelId))
          .toList(),
      nextCursor: json['next_cursor']?.toString(),
      previousCursor: json['previous_cursor']?.toString(),
    );
  }

  static ChatChannel channelFromJson(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      throw const FormatException('Channel item is not an object.');
    }
    final id = raw['id'] ?? raw['channel_id'];
    if (id == null) throw const FormatException('Channel id missing.');
    final lastActivityRaw =
        raw['lastActivity'] ?? raw['last_activity'] ?? raw['updated_at'];
    final lastActivity = lastActivityRaw == null
        ? DateTime.fromMillisecondsSinceEpoch(0)
        : DateTime.tryParse(lastActivityRaw.toString());
    if (lastActivity == null) {
      throw const FormatException('Channel last activity malformed.');
    }
    return ChatChannel(
      id: id.toString(),
      name: raw['name']?.toString() ?? raw['display_name']?.toString() ?? '',
      description: raw['description']?.toString() ?? '',
      isPrivate: raw['is_private'] == true || raw['isPrivate'] == true,
      unreadCount:
          (raw['unread_count'] as num?)?.toInt() ??
          (raw['unreadCount'] as num?)?.toInt() ??
          0,
      lastActivity: lastActivity,
    );
  }

  static ChatMessage messageFromJson(dynamic raw, String fallbackChannelId) {
    if (raw is! Map<String, dynamic>) {
      throw const FormatException('Message item is not an object.');
    }
    final id = raw['id'] ?? raw['message_id'];
    final timestampRaw =
        raw['timestamp'] ?? raw['created_at'] ?? raw['sort_ts'];
    if (id == null || timestampRaw == null) {
      throw const FormatException('Message required fields missing.');
    }
    final timestamp = DateTime.tryParse(timestampRaw.toString());
    if (timestamp == null) {
      throw const FormatException('Message timestamp malformed.');
    }
    return ChatMessage(
      id: id.toString(),
      channelId:
          raw['channelId']?.toString() ??
          raw['channel_id']?.toString() ??
          fallbackChannelId,
      senderName:
          raw['senderName']?.toString() ??
          raw['sender_name']?.toString() ??
          raw['author']?['name']?.toString() ??
          'Workspace Member',
      senderAvatar:
          raw['senderAvatar']?.toString() ??
          raw['sender_avatar']?.toString() ??
          raw['author']?['avatar_url']?.toString() ??
          '',
      text: raw['content']?.toString() ?? raw['text']?.toString() ?? '',
      timestamp: timestamp,
      isAgent: raw['is_agent'] == true || raw['isAgent'] == true,
      mentions:
          (raw['mentions'] as List?)?.map((item) => item.toString()).toList() ??
          [],
    );
  }
}

class MacroChatRepository implements ChatRepository {
  final MacroServiceConfig _config;
  final String? Function() _tokenProvider;
  final http.Client _client;
  final Uuid _uuid;
  String? _channelsNextCursor;
  final Map<String, String?> _messageNextCursorByChannel = {};

  MacroChatRepository({
    MacroServiceConfig? config,
    required this._tokenProvider,
    http.Client? client,
    Uuid? uuid,
  }) : _config = config ?? MacroServiceConfig.production(),
       _client = client ?? http.Client(),
       _uuid = uuid ?? const Uuid();

  String? get channelsNextCursor => _channelsNextCursor;
  String? messageNextCursor(String channelId) =>
      _messageNextCursorByChannel[channelId];

  @override
  Future<List<ChatChannel>> fetchChannels() async {
    final page = await fetchChannelsPage();
    return page.channels;
  }

  Future<MacroChannelPage> fetchChannelsPage({String? cursor}) async {
    final token = _requireToken();
    final uri = Uri.parse('${_config.storageHost}/comms/channels').replace(
      queryParameters: {
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      },
    );
    final response = await _client
        .get(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 4));

    if (response.statusCode != 200) {
      throw MacroApiException(
        'Failed to load channels.',
        statusCode: response.statusCode,
      );
    }

    final page = MacroChatMapper.channelsPageFromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
    _channelsNextCursor = page.nextCursor;
    return page;
  }

  @override
  Future<List<ChatMessage>> fetchMessages(String channelId) async {
    final page = await fetchMessagesPage(channelId);
    return page.messages;
  }

  Future<MacroMessagePage> fetchMessagesPage(
    String channelId, {
    String? cursor,
  }) async {
    final token = _requireToken();
    final uri = Uri.parse('${_config.storageHost}/channels/$channelId/messages')
        .replace(
          queryParameters: {
            if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
          },
        );
    final response = await _client
        .get(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 4));

    if (response.statusCode != 200) {
      throw MacroApiException(
        'Failed to load channel messages.',
        statusCode: response.statusCode,
      );
    }

    final page = MacroChatMapper.messagesPageFromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
      channelId,
    );
    _messageNextCursorByChannel[channelId] = page.nextCursor;
    return page;
  }

  @override
  Future<ChatMessage> sendMessage({
    required String channelId,
    required String text,
    required String senderName,
    required String senderAvatar,
    bool isAgent = false,
  }) async {
    final token = _requireToken();
    final response = await _client
        .post(
          Uri.parse('${_config.storageHost}/channels/$channelId/message'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'content': text,
            'mentions': <String>[],
            'attachments': <Object>[],
            'thread_id': null,
            'nonce': _uuid.v4(),
          }),
        )
        .timeout(const Duration(seconds: 4));

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw MacroApiException(
        'Failed to send channel message.',
        statusCode: response.statusCode,
      );
    }

    return MacroChatMapper.messageFromJson(
      jsonDecode(response.body),
      channelId,
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
