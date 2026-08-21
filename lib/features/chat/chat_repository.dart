import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/macro_service_config.dart';
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

class MacroChatRepository implements ChatRepository {
  final MacroServiceConfig _config;
  final String? Function() _tokenProvider;

  MacroChatRepository({
    MacroServiceConfig? config,
    required this._tokenProvider,
  }) : _config = config ?? MacroServiceConfig.production();

  @override
  Future<List<ChatChannel>> fetchChannels() async {
    final token = _tokenProvider();
    if (token == null || token.isEmpty) return [];

    try {
      // Verified Upstream Route: GET storageHost/comms/channels
      final response = await http
          .get(
            Uri.parse('${_config.storageHost}/comms/channels'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((item) => ChatChannel.fromJson(item)).toList();
      }
    } catch (_) {}

    return [];
  }

  @override
  Future<List<ChatMessage>> fetchMessages(String channelId) async {
    final token = _tokenProvider();
    if (token == null || token.isEmpty) return [];

    try {
      // Verified Upstream Route: GET storageHost/channels/{channel_id}/messages
      final response = await http
          .get(
            Uri.parse('${_config.storageHost}/channels/$channelId/messages'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((item) => ChatMessage.fromJson(item)).toList();
      }
    } catch (_) {}

    return [];
  }

  @override
  Future<ChatMessage> sendMessage({
    required String channelId,
    required String text,
    required String senderName,
    required String senderAvatar,
    bool isAgent = false,
  }) async {
    final token = _tokenProvider();
    if (token == null || token.isEmpty) {
      throw Exception(
        'Unauthenticated: Cannot send message without session token',
      );
    }

    // Verified Upstream Route: POST storageHost/channels/{channel_id}/messages
    final response = await http
        .post(
          Uri.parse('${_config.storageHost}/channels/$channelId/messages'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'text': text,
            'sender_name': senderName,
            'sender_avatar': senderAvatar,
            'is_agent': isAgent,
          }),
        )
        .timeout(const Duration(seconds: 4));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return ChatMessage.fromJson(data);
    } else {
      throw Exception(
        'HTTP ${response.statusCode} while sending channel message',
      );
    }
  }
}
