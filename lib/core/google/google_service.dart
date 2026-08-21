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

class MacroGoogleAccount {
  final String linkId;
  final String emailAddress;
  final String provider;
  final bool primary;
  final bool syncActive;
  final String syncStatus;
  final bool needsReauthentication;
  final String? photoUrl;

  const MacroGoogleAccount({
    required this.linkId,
    required this.emailAddress,
    required this.provider,
    required this.primary,
    required this.syncActive,
    required this.syncStatus,
    required this.needsReauthentication,
    this.photoUrl,
  });

  factory MacroGoogleAccount.fromJson(Map<String, dynamic> json) {
    final linkId = json['linkId'] ?? json['link_id'] ?? json['id'];
    final emailAddress =
        json['emailAddress'] ?? json['email_address'] ?? json['email'];
    if (linkId == null || emailAddress == null) {
      throw const FormatException('Google account link id/email missing.');
    }

    return MacroGoogleAccount(
      linkId: linkId.toString(),
      emailAddress: emailAddress.toString(),
      provider: json['provider']?.toString() ?? 'google',
      primary: json['primary'] == true || json['is_primary'] == true,
      syncActive: json['syncActive'] == true || json['sync_active'] == true,
      syncStatus:
          json['syncStatus']?.toString() ??
          json['sync_status']?.toString() ??
          'unknown',
      needsReauthentication:
          json['needsReauthentication'] == true ||
          json['needs_reauthentication'] == true ||
          json['reauthentication_required'] == true,
      photoUrl: json['photoUrl']?.toString() ?? json['photo_url']?.toString(),
    );
  }
}

class MacroCalendar {
  final String id;
  final String summary;
  final String? accountLinkId;
  final bool primary;

  const MacroCalendar({
    required this.id,
    required this.summary,
    this.accountLinkId,
    this.primary = false,
  });

  factory MacroCalendar.fromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? json['calendar_id'];
    if (id == null) throw const FormatException('Calendar id missing.');
    return MacroCalendar(
      id: id.toString(),
      summary: json['summary']?.toString() ?? json['name']?.toString() ?? '',
      accountLinkId: json['linkId']?.toString() ?? json['link_id']?.toString(),
      primary: json['primary'] == true || json['is_primary'] == true,
    );
  }
}

class MacroCalendarEvent {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String? meetingUrl;
  final String? calendarId;

  const MacroCalendarEvent({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.meetingUrl,
    this.calendarId,
  });

  factory MacroCalendarEvent.fromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? json['event_id'];
    final startRaw =
        json['start_time'] ??
        json['startTime'] ??
        json['start']?['dateTime'] ??
        json['start']?['date'];
    final endRaw =
        json['end_time'] ??
        json['endTime'] ??
        json['end']?['dateTime'] ??
        json['end']?['date'];

    if (id == null || startRaw == null || endRaw == null) {
      throw const FormatException('Calendar event required fields missing.');
    }

    final startTime = DateTime.tryParse(startRaw.toString());
    final endTime = DateTime.tryParse(endRaw.toString());
    if (startTime == null || endTime == null) {
      throw const FormatException('Calendar event dates malformed.');
    }

    return MacroCalendarEvent(
      id: id.toString(),
      title:
          json['title']?.toString() ??
          json['summary']?.toString() ??
          'Workspace Meeting',
      startTime: startTime,
      endTime: endTime,
      meetingUrl:
          json['meeting_url']?.toString() ?? json['hangoutLink']?.toString(),
      calendarId:
          json['calendarId']?.toString() ?? json['calendar_id']?.toString(),
    );
  }
}

class GoogleService extends ChangeNotifier {
  final MacroServiceConfig _config;
  final String? Function() _tokenProvider;
  final http.Client _client;

  GoogleConnectionState _state = GoogleConnectionState.notConnected;
  List<MacroGoogleAccount> _accounts = [];
  List<MacroCalendar> _calendars = [];
  List<MacroCalendarEvent> _calendarEvents = [];
  String? _errorMessage;

  GoogleService({
    MacroServiceConfig? config,
    required this._tokenProvider,
    http.Client? client,
  }) : _config = config ?? MacroServiceConfig.production(),
       _client = client ?? http.Client();

  GoogleConnectionState get state => _state;
  bool get isConnected => _state == GoogleConnectionState.connected;
  List<MacroGoogleAccount> get accounts => List.unmodifiable(_accounts);
  String? get connectedEmail =>
      _accounts.isEmpty ? null : _accounts.first.emailAddress;
  List<MacroCalendar> get calendars => List.unmodifiable(_calendars);
  List<MacroCalendarEvent> get calendarEvents =>
      List.unmodifiable(_calendarEvents);
  String? get errorMessage => _errorMessage;

  Uri buildGoogleSsoUri({String? loginHint, String? referralCode}) {
    return Uri.parse('${_config.authHost}/login/sso').replace(
      queryParameters: {
        'idp_name': 'google_gmail',
        'is_mobile': 'true',
        'original_url': 'macro://login',
        if (loginHint != null && loginHint.isNotEmpty) 'login_hint': loginHint,
        if (referralCode != null && referralCode.isNotEmpty)
          'referral_code': referralCode,
      },
    );
  }

  Future<void> checkConnectionStatus() async {
    final token = _tokenProvider();
    if (token == null || token.isEmpty) {
      _accounts = [];
      _setState(GoogleConnectionState.notConnected, null);
      return;
    }

    try {
      await fetchGoogleAccounts();
      if (_accounts.any((account) => account.needsReauthentication)) {
        _setState(GoogleConnectionState.needsReauth, null);
      } else if (_accounts.isNotEmpty) {
        _setState(GoogleConnectionState.connected, null);
        await fetchCalendars();
      } else {
        _setState(GoogleConnectionState.notConnected, null);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('checkConnectionStatus exception: $e');
      _setState(GoogleConnectionState.error, e.toString());
    }
  }

  Future<bool> initiateGoogleSso() async {
    _setState(GoogleConnectionState.linking, null);

    final uri = buildGoogleSsoUri();
    if (await _launchAuthorizationUri(uri)) {
      return true;
    }

    _setState(
      GoogleConnectionState.error,
      'Could not open Macro Google SSO authorization service.',
    );
    return false;
  }

  Future<bool> _launchAuthorizationUri(Uri uri) async {
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) {
        return true;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Authorization launch exception: $e');
    }

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      if (launched) {
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Authorization platform launch exception: $e');
      }
    }

    if (await canLaunchUrl(uri)) {
      final launched = await launchUrl(uri);
      if (launched) {
        return true;
      }
    }

    return false;
  }

  Future<bool> initiateGoogleOAuth() async {
    final token = _tokenProvider();
    if (token == null || token.isEmpty) return initiateGoogleSso();

    _setState(GoogleConnectionState.linking, null);
    final uri = Uri.parse('${_config.authHost}/link/gmail').replace(
      queryParameters: {
        'scopes': 'gmail_and_calendar',
        'original_url': 'macro://login',
      },
    );

    try {
      final response = await _client
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final authUrl =
            data['authorization_url']?.toString() ?? data['url']?.toString();
        if (authUrl != null && authUrl.isNotEmpty) {
          final authUri = Uri.parse(authUrl);
          if (await _launchAuthorizationUri(authUri)) {
            return true;
          }
        }
      }

      _setState(
        GoogleConnectionState.error,
        'Failed to obtain Gmail and Calendar authorization link.',
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

  Future<List<MacroGoogleAccount>> fetchGoogleAccounts() async {
    final token = _requireToken();
    final response = await _client
        .get(
          Uri.parse('${_config.emailHost}/email/links'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 4));

    if (response.statusCode != 200) {
      throw Exception('Email links failed with HTTP ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    final List items = decoded is Map<String, dynamic>
        ? decoded['items'] as List? ?? decoded['links'] as List? ?? []
        : decoded as List;
    _accounts = items.map((item) => MacroGoogleAccount.fromJson(item)).toList();
    notifyListeners();
    return _accounts;
  }

  Future<bool> fetchGmailReauthenticationRequired() async {
    final token = _requireToken();
    final response = await _client
        .get(
          Uri.parse('${_config.authHost}/link/gmail/status'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 4));

    if (response.statusCode != 200) {
      throw Exception('Gmail status failed with HTTP ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['reauthentication_required'] == true;
  }

  Future<List<MacroCalendar>> fetchCalendars() async {
    final token = _requireToken();
    final response = await _client
        .get(
          Uri.parse('${_config.emailHost}/calendar/calendars'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 4));

    if (response.statusCode != 200) {
      throw Exception('Calendar list failed with HTTP ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    final List items = decoded is Map<String, dynamic>
        ? decoded['items'] as List? ?? decoded['calendars'] as List? ?? []
        : decoded as List;
    _calendars = items.map((item) => MacroCalendar.fromJson(item)).toList();
    notifyListeners();
    return _calendars;
  }

  Future<List<MacroCalendarEvent>> fetchCalendarEvents({
    DateTime? start,
    DateTime? end,
  }) async {
    final token = _requireToken();
    final uri = Uri.parse('${_config.storageHost}/calendar-events').replace(
      queryParameters: {
        if (start != null) 'start': start.toIso8601String(),
        if (end != null) 'end': end.toIso8601String(),
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
      throw Exception(
        'Calendar occurrences failed with HTTP ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);
    final List items = decoded is Map<String, dynamic>
        ? decoded['items'] as List? ?? decoded['events'] as List? ?? []
        : decoded as List;
    _calendarEvents = items
        .map((item) => MacroCalendarEvent.fromJson(item))
        .toList();
    notifyListeners();
    return _calendarEvents;
  }

  Future<void> disconnectGoogle({String? linkId}) async {
    final token = _tokenProvider();
    final targetLinkId =
        linkId ?? (_accounts.isEmpty ? null : _accounts.first.linkId);
    if (token == null || token.isEmpty || targetLinkId == null) return;

    await _client
        .delete(
          Uri.parse('${_config.emailHost}/email/links/$targetLinkId'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 3));

    _accounts = _accounts
        .where((account) => account.linkId != targetLinkId)
        .toList();
    _calendarEvents = [];
    _calendars = [];
    _setState(
      _accounts.isEmpty
          ? GoogleConnectionState.notConnected
          : GoogleConnectionState.connected,
      null,
    );
  }

  String _requireToken() {
    final token = _tokenProvider();
    if (token == null || token.isEmpty) {
      throw StateError('No active session token.');
    }
    return token;
  }

  void _setState(GoogleConnectionState newState, String? error) {
    _state = newState;
    _errorMessage = error;
    notifyListeners();
  }
}
