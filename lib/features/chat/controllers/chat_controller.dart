import 'package:flutter/foundation.dart';
import '../../../core/persistence/local_cache.dart';
import '../../../core/realtime/realtime_client.dart';
import '../../../models/models.dart';
import '../chat_repository.dart';

class ChatController extends ChangeNotifier {
  final ChatRepository repository;
  final LocalCacheStore cacheStore;
  final RealtimeClient realtimeClient;

  List<ChatChannel> _channels = [];
  ChatChannel? _activeChannel;
  List<ChatMessage> _activeMessages = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ChatChannel> get channels => List.unmodifiable(_channels);
  ChatChannel? get activeChannel => _activeChannel;
  List<ChatMessage> get activeMessages => List.unmodifiable(_activeMessages);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ChatController({
    required this.repository,
    required this.cacheStore,
    required this.realtimeClient,
  });

  Future<void> loadChannels() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _channels = await repository.fetchChannels();
      if (_channels.isNotEmpty && _activeChannel == null) {
        _activeChannel = _channels.first;
      }
      if (_activeChannel != null) {
        await loadMessagesForChannel(_activeChannel!.id);
      }
    } catch (e) {
      _errorMessage = 'Failed to load channels: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectChannel(String channelId) async {
    final channel = _channels.firstWhere(
      (c) => c.id == channelId,
      orElse: () => _channels.first,
    );
    _activeChannel = channel;
    notifyListeners();
    await loadMessagesForChannel(channelId);
  }

  Future<void> loadMessagesForChannel(String channelId) async {
    try {
      _activeMessages = await repository.fetchMessages(channelId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load messages: $e';
      notifyListeners();
    }
  }

  Future<void> sendMessage({
    required String text,
    required String senderName,
    required String senderAvatar,
    bool isAgent = false,
  }) async {
    if (_activeChannel == null || text.trim().isEmpty) return;

    try {
      final message = await repository.sendMessage(
        channelId: _activeChannel!.id,
        text: text,
        senderName: senderName,
        senderAvatar: senderAvatar,
        isAgent: isAgent,
      );

      _activeMessages = [..._activeMessages, message];
      notifyListeners();

      // Emit event over realtime transport
      realtimeClient.sendEvent(
        RealtimeEvent(
          type: 'chat_message_created',
          payload: {
            'id': message.id,
            'channelId': message.channelId,
            'text': message.text,
            'senderName': message.senderName,
          },
        ),
      );
    } catch (e) {
      _errorMessage = 'Failed to send message: $e';
      notifyListeners();
    }
  }
}
