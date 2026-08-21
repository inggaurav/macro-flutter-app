import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../config/macro_service_config.dart';
import '../../models/models.dart';
import '../storage/secure_key_value_store.dart';

class GoogleCalendarEvent {
  final String id;
  final String summary;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final String? hangoutsLink;

  GoogleCalendarEvent({
    required this.id,
    required this.summary,
    this.description,
    required this.startTime,
    required this.endTime,
    this.hangoutsLink,
  });

  factory GoogleCalendarEvent.fromJson(Map<String, dynamic> json) {
    return GoogleCalendarEvent(
      id: json['id']?.toString() ?? '',
      summary: json['summary']?.toString() ?? 'Workspace Meeting',
      description: json['description']?.toString(),
      startTime:
          DateTime.tryParse(json['start']?['dateTime']?.toString() ?? '') ??
          DateTime.now(),
      endTime:
          DateTime.tryParse(json['end']?['dateTime']?.toString() ?? '') ??
          DateTime.now().add(const Duration(hours: 1)),
      hangoutsLink: json['hangoutLink']?.toString(),
    );
  }
}

class GoogleService extends ChangeNotifier {
  final MacroServiceConfig _config;
  final SecureKeyValueStore _storage;

  bool _isGoogleConnected = false;
  String? _googleEmail;
  String? _googleAccessToken;
  List<GoogleCalendarEvent> _calendarEvents = [];

  GoogleService({MacroServiceConfig? config, SecureKeyValueStore? storage})
    : _config = config ?? MacroServiceConfig.production(),
      _storage = storage ?? PlatformSecureStorageService();

  bool get isConnected => _isGoogleConnected;
  String? get googleEmail => _googleEmail;
  List<GoogleCalendarEvent> get calendarEvents =>
      List.unmodifiable(_calendarEvents);

  Future<void> restoreGoogleSession() async {
    final email = await _storage.read('google_user_email');
    final token = await _storage.read('google_access_token');

    if (token != null && token.isNotEmpty) {
      _googleAccessToken = token;
      _googleEmail = email;
      _isGoogleConnected = true;
      notifyListeners();
      await fetchCalendarEvents();
    }
  }

  Future<String?> initiateGoogleOAuth() async {
    try {
      final response = await http
          .post(
            Uri.parse('${_config.emailHost}/v1/link/gmail'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final authUrl = data['authorization_url']?.toString();
        if (authUrl != null) {
          final uri = Uri.parse(authUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
          return authUrl;
        }
      }
    } catch (e) {
      if (kDebugMode) print('GoogleOAuth Exception: $e');
    }

    // Direct Google OAuth authorization endpoint fallback
    const directAuthUrl =
        'https://accounts.google.com/o/oauth2/v2/auth'
        '?response_type=code'
        '&client_id=macro-google-workspace.apps.googleusercontent.com'
        '&redirect_uri=https://auth-service.macro.com/oauth/google/callback'
        '&scope=openid%20email%20profile%20https://www.googleapis.com/auth/gmail.readonly%20https://www.googleapis.com/auth/calendar.readonly'
        '&access_type=offline';

    final uri = Uri.parse(directAuthUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return directAuthUrl;
  }

  Future<bool> saveGoogleSession({
    required String email,
    required String accessToken,
  }) async {
    _googleEmail = email;
    _googleAccessToken = accessToken;
    _isGoogleConnected = true;

    await _storage.write('google_user_email', email);
    await _storage.write('google_access_token', accessToken);

    notifyListeners();
    await fetchCalendarEvents();
    return true;
  }

  Future<List<GoogleCalendarEvent>> fetchCalendarEvents() async {
    if (_googleAccessToken == null) return [];

    try {
      final response = await http
          .get(
            Uri.parse(
              'https://www.googleapis.com/calendar/v3/calendars/primary/events?timeMin=${DateTime.now().toIso8601String()}',
            ),
            headers: {'Authorization': 'Bearer $_googleAccessToken'},
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List items = data['items'] ?? [];
        _calendarEvents = items
            .map((item) => GoogleCalendarEvent.fromJson(item))
            .toList();
        notifyListeners();
        return _calendarEvents;
      }
    } catch (_) {}

    return [];
  }

  Future<void> disconnectGoogle() async {
    _isGoogleConnected = false;
    _googleEmail = null;
    _googleAccessToken = null;
    _calendarEvents = [];

    await _storage.delete('google_user_email');
    await _storage.delete('google_access_token');
    notifyListeners();
  }
}
