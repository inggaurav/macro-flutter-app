import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/persistence/local_cache.dart';
import '../../../core/realtime/realtime_client.dart';
import '../chat_repository.dart';
import '../domain/chat_channel.dart';
import '../domain/chat_message.dart';

class ChatController extends ChangeNotifier {
  final ChatRepository repository;
  final LocalCacheStore cacheStore;
  final RealtimeClient realtimeClient;
  final String workspaceId;

  List<ChatChannel> _channels = [];
  ChatChannel? _activeChannel;
  List<ChatMessage> _activeMessages = [];
  bool _isLoadingChannels = false;
  bool _isLoadingMessages = false;
  bool _isSendingMessage = false;
  String? _errorMessage;
  RealtimeState _realtimeState = RealtimeState.disconnected;

  StreamSubscription<RealtimeEvent>? _eventSubscription;
  StreamSubscription<RealtimeState>? _stateSubscription;

  List<ChatChannel> get channels => List.unmodifiable(_channels);
  ChatChannel? get activeChannel => _activeChannel;
  List<ChatMessage> get activeMessages => List.unmodifiable(_activeMessages);
  bool get isLoadingChannels => _isLoadingChannels;
  bool get isLoadingMessages => _isLoadingMessages;
  bool get isSendingMessage => _isSendingMessage;
  String? get errorMessage => _errorMessage;
  RealtimeState get realtimeState => _realtimeState;

  String get _channelsCacheKey => 'workspace:$workspaceId:chat:channels';
  String _messagesCacheKey(String channelId) =>
      'workspace:$workspaceId:chat:messages:$channelId';

  ChatController({
    required this.repository,
    required this.cacheStore,
    required this.realtimeClient,
    this.workspaceId = 'default',
  }) {
    _initRealtime();
  }

  void _initRealtime() {
    _realtimeState = realtimeClient.state;
    _stateSubscription = realtimeClient.stateStream.listen((state) {
      _realtimeState = state;
      notifyListeners();
    });

    _eventSubscription = realtimeClient.eventStream.listen((event) {
      if (event.type == 'chat_message_created') {
        _handleIncomingRealtimeMessage(event.payload);
      }
    });

    realtimeClient.connect();
  }

  Future<void> loadChannels() async {
    _isLoadingChannels = true;
    _errorMessage = null;
    notifyListeners();

    // 1. Read cached channels first for immediate UI render
    final cachedJson = await cacheStore.get(_channelsCacheKey);
    if (cachedJson is List) {
      try {
        _channels = cachedJson
            .map((e) => ChatChannel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        if (_channels.isNotEmpty && _activeChannel == null) {
          _activeChannel = _channels.first;
        }
        notifyListeners();
      } catch (_) {}
    }

    // 2. Fetch repository data (stale-while-revalidate)
    try {
      final remoteChannels = await repository.fetchChannels();
      _channels = remoteChannels;

      if (_channels.isNotEmpty && _activeChannel == null) {
        _activeChannel = _channels.first;
      }

      // 3. Persist to cache
      final jsonList = _channels.map((c) => c.toJson()).toList();
      await cacheStore.put(_channelsCacheKey, jsonList);

      if (_activeChannel != null) {
        await loadMessagesForChannel(_activeChannel!.id);
      }
    } catch (e) {
      _errorMessage = 'Failed to load channels: $e';
    } finally {
      _isLoadingChannels = false;
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
    _isLoadingMessages = true;
    notifyListeners();

    final cacheKey = _messagesCacheKey(channelId);

    // 1. Read cached messages first
    final cachedJson = await cacheStore.get(cacheKey);
    if (cachedJson is List) {
      try {
        _activeMessages = cachedJson
            .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        notifyListeners();
      } catch (_) {}
    }

    // 2. Fetch repository messages
    try {
      final remoteMessages = await repository.fetchMessages(channelId);
      _activeMessages = remoteMessages;

      // 3. Persist to cache
      final jsonList = _activeMessages.map((m) => m.toJson()).toList();
      await cacheStore.put(cacheKey, jsonList);
    } catch (e) {
      _errorMessage = 'Failed to load messages: $e';
    } finally {
      _isLoadingMessages = false;
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

    _isSendingMessage = true;
    notifyListeners();

    try {
      final message = await repository.sendMessage(
        channelId: _activeChannel!.id,
        text: text,
        senderName: senderName,
        senderAvatar: senderAvatar,
        isAgent: isAgent,
      );

      _activeMessages = [..._activeMessages, message];

      // Update cache
      final jsonList = _activeMessages.map((m) => m.toJson()).toList();
      await cacheStore.put(_messagesCacheKey(_activeChannel!.id), jsonList);

      // Emit event over realtime transport
      realtimeClient.sendEvent(
        RealtimeEvent(type: 'chat_message_created', payload: message.toJson()),
      );
    } catch (e) {
      _errorMessage = 'Failed to send message: $e';
    } finally {
      _isSendingMessage = false;
      notifyListeners();
    }
  }

  void _handleIncomingRealtimeMessage(Map<String, dynamic> payload) {
    try {
      final message = ChatMessage.fromJson(payload);
      // Ignore if message belongs to another channel or is already present
      if (_activeChannel == null || message.channelId != _activeChannel!.id)
        return;
      if (_activeMessages.any((m) => m.id == message.id)) return;

      _activeMessages = [..._activeMessages, message];
      notifyListeners();

      // Persist updated cache
      final jsonList = _activeMessages.map((m) => m.toJson()).toList();
      cacheStore.put(_messagesCacheKey(_activeChannel!.id), jsonList);
    } catch (_) {}
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _stateSubscription?.cancel();
    super.dispose();
  }
}
