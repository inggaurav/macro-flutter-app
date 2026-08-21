import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../realtime/realtime_client.dart';

class MacroRealtimeClient implements RealtimeClient {
  final String gatewayUrl;
  final String? Function() tokenProvider;

  RealtimeState _state = RealtimeState.disconnected;
  final StreamController<RealtimeState> _stateController =
      StreamController<RealtimeState>.broadcast();
  final StreamController<RealtimeEvent> _eventController =
      StreamController<RealtimeEvent>.broadcast();

  WebSocketChannel? _channel;
  StreamSubscription? _channelSubscription;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  bool _isDisposed = false;

  MacroRealtimeClient({required this.gatewayUrl, required this.tokenProvider});

  @override
  RealtimeState get state => _state;

  @override
  Stream<RealtimeState> get stateStream => _stateController.stream;

  @override
  Stream<RealtimeEvent> get eventStream => _eventController.stream;

  @override
  Future<void> connect() async {
    if (_isDisposed) return;
    final token = tokenProvider();
    if (token == null || token.isEmpty) {
      _setState(RealtimeState.disconnected);
      return;
    }

    _setState(RealtimeState.connecting);

    try {
      final wsUri = Uri.parse(
        gatewayUrl,
      ).replace(queryParameters: {'token': token});

      _channel = WebSocketChannel.connect(wsUri);
      await _channel?.ready.timeout(const Duration(seconds: 5));

      _setState(RealtimeState.connected);
      _reconnectAttempts = 0;
      _startHeartbeat();

      _channelSubscription = _channel?.stream.listen(
        (data) {
          _onIncomingFrame(data);
        },
        onError: (error) {
          if (kDebugMode) print('MacroRealtimeClient WebSocket error: $error');
          _handleDisconnect();
        },
        onDone: () {
          if (kDebugMode) {
            print('MacroRealtimeClient WebSocket closed by gateway');
          }
          _handleDisconnect();
        },
      );
    } catch (e) {
      if (kDebugMode) print('MacroRealtimeClient connect exception: $e');
      _handleDisconnect();
    }
  }

  @override
  Future<void> disconnect() async {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    await _channelSubscription?.cancel();
    await _channel?.sink.close();
    _channel = null;
    _setState(RealtimeState.disconnected);
  }

  @override
  Future<void> sendEvent(RealtimeEvent event) async {
    if (_state != RealtimeState.connected || _channel == null) return;

    try {
      final payload = jsonEncode({
        'type': event.type,
        'payload': event.payload,
        'timestamp': event.timestamp.toIso8601String(),
      });
      _channel?.sink.add(payload);
    } catch (e) {
      if (kDebugMode) print('MacroRealtimeClient send error: $e');
    }
  }

  void _onIncomingFrame(dynamic data) {
    try {
      final Map<String, dynamic> json = jsonDecode(data.toString());
      final type = json['type']?.toString() ?? 'event';
      final payload = (json['payload'] as Map<String, dynamic>?) ?? {};

      if (type == 'pong') return; // Heartbeat pong response

      final event = RealtimeEvent(
        type: type,
        payload: payload,
        timestamp:
            DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
            DateTime.now(),
      );
      _eventController.add(event);
    } catch (_) {}
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      if (_state == RealtimeState.connected && _channel != null) {
        try {
          _channel?.sink.add(
            jsonEncode({
              'type': 'ping',
              'timestamp': DateTime.now().toIso8601String(),
            }),
          );
        } catch (_) {}
      }
    });
  }

  void _handleDisconnect() {
    _heartbeatTimer?.cancel();
    if (_isDisposed) return;

    _setState(RealtimeState.reconnecting);
    _reconnectTimer?.cancel();

    if (_reconnectAttempts < 5) {
      _reconnectAttempts++;
      final delaySeconds = _reconnectAttempts * 2;
      _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
        connect();
      });
    } else {
      _setState(RealtimeState.failed);
    }
  }

  void _setState(RealtimeState newState) {
    if (_state != newState) {
      _state = newState;
      _stateController.add(_state);
    }
  }

  Future<void> dispose() async {
    _isDisposed = true;
    await disconnect();
    await _stateController.close();
    await _eventController.close();
  }
}
