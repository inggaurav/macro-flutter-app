import 'dart:async';
import 'package:flutter/foundation.dart';
import '../realtime/realtime_client.dart';

class MacroRealtimeClient implements RealtimeClient {
  final String gatewayUrl;
  final String? Function() tokenProvider;

  RealtimeState _state = RealtimeState.disconnected;
  final StreamController<RealtimeState> _stateController = StreamController<RealtimeState>.broadcast();
  final StreamController<RealtimeEvent> _eventController = StreamController<RealtimeEvent>.broadcast();
  Timer? _heartbeatTimer;

  MacroRealtimeClient({
    required this.gatewayUrl,
    required this.tokenProvider,
  });

  @override
  RealtimeState get state => _state;

  @override
  Stream<RealtimeState> get stateStream => _stateController.stream;

  @override
  Stream<RealtimeEvent> get eventStream => _eventController.stream;

  @override
  Future<void> connect() async {
    final token = tokenProvider();
    if (token == null || token.isEmpty) {
      if (kDebugMode) print('MacroRealtimeClient: Cannot connect without bearer token');
      _setState(RealtimeState.disconnected);
      return;
    }

    _setState(RealtimeState.connecting);
    _setState(RealtimeState.connected);
    _startHeartbeat();
    if (kDebugMode) print('MacroRealtimeClient: Connected to gateway at $gatewayUrl');
  }

  @override
  Future<void> disconnect() async {
    _heartbeatTimer?.cancel();
    _setState(RealtimeState.disconnected);
    if (kDebugMode) print('MacroRealtimeClient: Disconnected gateway');
  }

  @override
  Future<void> sendEvent(RealtimeEvent event) async {
    if (_state != RealtimeState.connected) return;
    _eventController.add(event);
  }

  void _setState(RealtimeState newState) {
    _state = newState;
    _stateController.add(_state);
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_state == RealtimeState.connected) {
        if (kDebugMode) print('MacroRealtimeClient: Heartbeat ping sent');
      }
    });
  }

  Future<void> dispose() async {
    await disconnect();
    await _stateController.close();
    await _eventController.close();
  }
}
