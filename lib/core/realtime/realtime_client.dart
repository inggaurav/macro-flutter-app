import 'dart:async';

enum RealtimeState { connecting, connected, reconnecting, disconnected, failed }

class RealtimeEvent {
  final String type;
  final Map<String, dynamic> payload;
  final DateTime timestamp;

  RealtimeEvent({
    required this.type,
    required this.payload,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

abstract interface class RealtimeClient {
  RealtimeState get state;
  Stream<RealtimeState> get stateStream;
  Stream<RealtimeEvent> get eventStream;

  Future<void> connect();
  Future<void> disconnect();
  Future<void> sendEvent(RealtimeEvent event);
}

class MockRealtimeClient implements RealtimeClient {
  RealtimeState _state = RealtimeState.disconnected;
  final _stateController = StreamController<RealtimeState>.broadcast();
  final _eventController = StreamController<RealtimeEvent>.broadcast();

  @override
  RealtimeState get state => _state;

  @override
  Stream<RealtimeState> get stateStream => _stateController.stream;

  @override
  Stream<RealtimeEvent> get eventStream => _eventController.stream;

  @override
  Future<void> connect() async {
    _setState(RealtimeState.connecting);
    await Future.delayed(const Duration(milliseconds: 200));
    _setState(RealtimeState.connected);
  }

  @override
  Future<void> disconnect() async {
    _setState(RealtimeState.disconnected);
  }

  @override
  Future<void> sendEvent(RealtimeEvent event) async {
    _eventController.add(event);
  }

  void _setState(RealtimeState newState) {
    _state = newState;
    _stateController.add(_state);
  }
}
