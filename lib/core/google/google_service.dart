import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../config/macro_service_config.dart';

enum GoogleConnectionState {
  notConnected,
  linking,
  connected,
  needsReauth,
  error,
}

class MacroCalendarEvent {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String? meetingUrl;

  MacroCalendarEvent({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.meetingUrl,
  });

  factory MacroCalendarEvent.fromJson(Map<String, dynamic> json) {
    return MacroCalendarEvent(
      id: json['id']?.toString() ?? '',
      title:
          json['title']?.toString() ??
          json['summary']?.toString() ??
          'Workspace Meeting',
      startTime:
          DateTime.tryParse(
            json['start_time']?.toString() ??
                json['start']?['dateTime']?.toString() ??
                '',
          ) ??
          DateTime.now(),
      endTime:
          DateTime.tryParse(
            json['end_time']?.toString() ??
                json['end']?['dateTime']?.toString() ??
                '',
          ) ??
          DateTime.now().add(const Duration(hours: 1)),
      meetingUrl:
          json['meeting_url']?.toString() ?? json['hangoutLink']?.toString(),
    );
  }
}

class GoogleService extends ChangeNotifier {
  final MacroServiceConfig _config;
  final String? Function() _tokenProvider;

  GoogleConnectionState _state = GoogleConnectionState.notConnected;
  String? _connectedEmail;
  List<MacroCalendarEvent> _calendarEvents = [];
  String? _errorMessage;

  GoogleService({
    MacroServiceConfig? config,
    required String? Function() tokenProvider,
  }) : _config = config ?? MacroServiceConfig.production(),
       _tokenProvider = tokenProvider;

  GoogleConnectionState get state => _state;
  bool get isConnected => _state == GoogleConnectionState.connected;
  String? get connectedEmail => _connectedEmail;
  List<MacroCalendarEvent> get calendarEvents =>
      List.unmodifiable(_calendarEvents);
  String? get errorMessage => _errorMessage;

  Future<void> checkConnectionStatus() async {
    final token = _tokenProvider();
    if (token == null || token.isEmpty) {
      _setState(GoogleConnectionState.notConnected, null);
      return;
    }

    try {
      // Verified Upstream Route: GET authHost/link/gmail/status
      final response = await http
          .get(
            Uri.parse('${_config.authHost}/link/gmail/status'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final bool isLinked =
            data['connected'] == true || data['status'] == 'connected';
        final email = data['email']?.toString();

        if (isLinked && email != null && email.isNotEmpty) {
          _connectedEmail = email;
          _setState(GoogleConnectionState.connected, null);
          await fetchCalendarEvents();
        } else {
          _setState(GoogleConnectionState.notConnected, null);
        }
      } else {
        _setState(GoogleConnectionState.notConnected, null);
      }
    } catch (e) {
      if (kDebugMode) print('checkConnectionStatus exception: $e');
      _setState(GoogleConnectionState.notConnected, null);
    }
  }

  Future<bool> initiateGoogleOAuth() async {
    final token = _tokenProvider();
    if (token == null || token.isEmpty) {
      _setState(
        GoogleConnectionState.error,
        'Unauthenticated: Must sign in to Macro before connecting Google.',
      );
      return false;
    }

    _setState(GoogleConnectionState.linking, null);

    try {
      // Verified Upstream Route: POST authHost/link/gmail
      final response = await http
          .post(
            Uri.parse('${_config.authHost}/link/gmail'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final authUrl = data['authorization_url']?.toString();
        if (authUrl != null && authUrl.isNotEmpty) {
          final uri = Uri.parse(authUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            return true;
          }
        }
      }
      _setState(
        GoogleConnectionState.error,
        'Failed to obtain Gmail authorization link from auth-service.',
      );
      return false;
    } catch (e) {
      _setState(
        GoogleConnectionState.error,
        'Network error initiating Google OAuth: $e',
      );
      return false;
    }
  }

  Future<List<MacroCalendarEvent>> fetchCalendarEvents() async {
    final token = _tokenProvider();
    if (token == null || token.isEmpty) return [];

    try {
      // Verified Upstream Route: GET emailHost/email/calendar/events
      final response = await http
          .get(
            Uri.parse('${_config.emailHost}/email/calendar/events'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        _calendarEvents = data
            .map((item) => MacroCalendarEvent.fromJson(item))
            .toList();
        notifyListeners();
        return _calendarEvents;
      }
    } catch (_) {}

    return [];
  }

  Future<void> disconnectGoogle() async {
    final token = _tokenProvider();
    if (token != null && token.isNotEmpty) {
      try {
        await http
            .delete(
              Uri.parse('${_config.authHost}/link/gmail'),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
            )
            .timeout(const Duration(seconds: 3));
      } catch (_) {}
    }
    _connectedEmail = null;
    _calendarEvents = [];
    _setState(GoogleConnectionState.notConnected, null);
  }

  void _setState(GoogleConnectionState newState, String? error) {
    _state = newState;
    _errorMessage = error;
    notifyListeners();
  }
}
