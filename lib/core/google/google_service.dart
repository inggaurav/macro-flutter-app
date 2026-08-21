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

class ConnectedGoogleAccount {
  final String id;
  final String emailAddress;
  final String provider;
  final bool isPrimary;
  final bool isSyncActive;
  final String syncStatus;
  final bool needsReauth;
  final String? photoUrl;

  const ConnectedGoogleAccount({
    required this.id,
    required this.emailAddress,
    required this.provider,
    required this.isPrimary,
    required this.isSyncActive,
    required this.syncStatus,
    required this.needsReauth,
    this.photoUrl,
  });

  factory ConnectedGoogleAccount.fromJson(Map<String, dynamic> json) {
    return ConnectedGoogleAccount(
      id: json['id']?.toString() ?? '',
      emailAddress: json['email_address']?.toString() ?? '',
      provider: json['provider']?.toString() ?? '',
      isPrimary: json['is_primary'] == true,
      isSyncActive: json['is_sync_active'] == true,
      syncStatus: json['sync_status']?.toString() ?? 'unknown',
      needsReauth: json['needs_reauth'] == true,
      photoUrl: json['photo_url']?.toString(),
    );
  }
}

class MacroCalendarSource {
  final String id;
  final String name;
  final String emailAddress;
  final String emailLinkId;
  final bool isPrimary;
  final bool isWritable;
  final String? color;

  const MacroCalendarSource({
    required this.id,
    required this.name,
    required this.emailAddress,
    required this.emailLinkId,
    required this.isPrimary,
    required this.isWritable,
    this.color,
  });

  factory MacroCalendarSource.fromJson(Map<String, dynamic> json) {
    return MacroCalendarSource(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Calendar',
      emailAddress: json['emailAddress']?.toString() ?? '',
      emailLinkId: json['emailLinkId']?.toString() ?? '',
      isPrimary: json['isPrimary'] == true,
      isWritable: json['isWritable'] == true,
      color: json['color']?.toString(),
    );
  }
}

class MacroCalendarEvent {
  final String id;
  final String occurrenceKey;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAllDay;
  final bool isCancelled;
  final String? calendarId;
  final String? description;
  final String? location;
  final String? organizerEmail;
  final String? organizerName;
  final String? meetingUrl;
  final bool isReadOnly;
  final List<Map<String, dynamic>> attendees;

  const MacroCalendarEvent({
    required this.id,
    required this.occurrenceKey,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.isAllDay,
    required this.isCancelled,
    required this.isReadOnly,
    required this.attendees,
    this.calendarId,
    this.description,
    this.location,
    this.organizerEmail,
    this.organizerName,
    this.meetingUrl,
  });

  factory MacroCalendarEvent.fromOccurrenceJson(Map<String, dynamic> json) {
    final event = _asMap(json['event']);
    final occurrence = _asMap(json['occurrence']);
    final occurrenceTime = _asMap(occurrence['time']);
    final eventTime = _asMap(event['time']);
    final time = occurrenceTime.isNotEmpty ? occurrenceTime : eventTime;

    final startsAt = time['startsAt']?.toString();
    final endsAt = time['endsAt']?.toString();
    final startDate = time['startDate']?.toString();
    final endDate = time['endDate']?.toString();
    final isAllDay = startDate != null && startDate.isNotEmpty;

    DateTime parseOrFallback(String? value, DateTime fallback) =>
        DateTime.tryParse(value ?? '') ?? fallback;

    final start = isAllDay
        ? parseOrFallback(startDate, DateTime.now())
        : parseOrFallback(startsAt, DateTime.now());
    final end = isAllDay
        ? parseOrFallback(endDate, start.add(const Duration(days: 1)))
        : parseOrFallback(endsAt, start.add(const Duration(hours: 1)));

    final rawAttendees = event['attendees'];
    final attendees = rawAttendees is List
        ? rawAttendees
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList()
        : <Map<String, dynamic>>[];

    return MacroCalendarEvent(
      id: event['id']?.toString() ?? occurrence['eventId']?.toString() ?? '',
      occurrenceKey: occurrence['occurrenceKey']?.toString() ?? '',
      title: event['title']?.toString() ?? 'Untitled event',
      startTime: start,
      endTime: end,
      isAllDay: isAllDay,
      isCancelled: occurrence['isCancelled'] == true,
      calendarId: event['calendarId']?.toString(),
      description: event['description']?.toString(),
      location: event['location']?.toString(),
      organizerEmail: event['organizerEmail']?.toString(),
      organizerName: event['organizerName']?.toString(),
      meetingUrl: event['conferenceUrl']?.toString(),
      isReadOnly: event['isReadOnly'] == true,
      attendees: attendees,
    );
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return const <String, dynamic>{};
  }
}

class GoogleService extends ChangeNotifier {
  static const _googleLinkCallback = 'macro://google-link-callback';

  final MacroServiceConfig _config;
  final String? Function() _tokenProvider;

  GoogleConnectionState _state = GoogleConnectionState.notConnected;
  List<ConnectedGoogleAccount> _accounts = [];
  List<MacroCalendarSource> _calendars = [];
  List<MacroCalendarEvent> _calendarEvents = [];
  String? _errorMessage;
  bool _calendarSyncing = false;

  GoogleService({
    MacroServiceConfig? config,
    required String? Function() tokenProvider,
  }) : _config = config ?? MacroServiceConfig.production(),
       _tokenProvider = tokenProvider;

  GoogleConnectionState get state => _state;
  bool get isConnected => _state == GoogleConnectionState.connected;
  bool get hasCalendarAccess => _calendars.isNotEmpty;
  bool get calendarSyncing => _calendarSyncing;
  String? get connectedEmail {
    if (_accounts.isEmpty) return null;
    return _accounts
        .firstWhere(
          (account) => account.isPrimary,
          orElse: () => _accounts.first,
        )
        .emailAddress;
  }

  List<ConnectedGoogleAccount> get accounts => List.unmodifiable(_accounts);
  List<MacroCalendarSource> get calendars => List.unmodifiable(_calendars);
  List<MacroCalendarEvent> get calendarEvents =>
      List.unmodifiable(_calendarEvents);
  String? get errorMessage => _errorMessage;

  Future<void> checkConnectionStatus() async {
    final token = _tokenProvider();
    if (token == null || token.isEmpty) {
      _accounts = [];
      _calendars = [];
      _calendarEvents = [];
      _setState(GoogleConnectionState.notConnected, null);
      return;
    }

    try {
      // Email links are the authoritative source for whether an inbox is
      // connected and which account it belongs to.
      final linksResponse = await http
          .get(
            Uri.parse('${_config.emailHost}/email/links'),
            headers: _authHeaders(token),
          )
          .timeout(const Duration(seconds: 10));

      if (linksResponse.statusCode == 401 ||
          linksResponse.statusCode == 403) {
        _setState(
          GoogleConnectionState.error,
          'The Macro session is not authorized to read connected inboxes.',
        );
        return;
      }
      if (linksResponse.statusCode != 200) {
        _setState(
          GoogleConnectionState.error,
          'Could not load connected Gmail accounts (HTTP ${linksResponse.statusCode}).',
        );
        return;
      }

      final payload = _decodeMap(linksResponse.body);
      final rawLinks = payload['links'];
      final links = rawLinks is List ? rawLinks : const [];
      _accounts = links
          .whereType<Map>()
          .map((item) => ConnectedGoogleAccount.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .where(
            (account) =>
                account.id.isNotEmpty &&
                account.provider.toUpperCase().contains('GMAIL'),
          )
          .toList();

      if (_accounts.isEmpty) {
        _calendars = [];
        _calendarEvents = [];
        _setState(GoogleConnectionState.notConnected, null);
        return;
      }

      var needsReauth = _accounts.any((account) => account.needsReauth);
      try {
        final statusResponse = await http
            .get(
              Uri.parse('${_config.authHost}/link/gmail/status'),
              headers: _authHeaders(token),
            )
            .timeout(const Duration(seconds: 8));
        if (statusResponse.statusCode == 428) {
          needsReauth = true;
        } else if (statusResponse.statusCode == 200) {
          final status = _decodeMap(statusResponse.body);
          needsReauth =
              needsReauth || status['reauthentication_required'] == true;
        }
      } catch (_) {
        // The email-links state remains useful even if the separate auth probe
        // is temporarily unavailable.
      }

      if (needsReauth) {
        _setState(
          GoogleConnectionState.needsReauth,
          'Google authorization needs to be renewed.',
        );
        return;
      }

      _setState(GoogleConnectionState.connected, null);
      await fetchCalendars();
      await fetchCalendarEvents();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Google connection status failed: $e');
      }
      _setState(
        GoogleConnectionState.error,
        'Could not verify Google connection: $e',
      );
    }
  }

  /// Connects a Gmail account and requests Calendar incrementally in the same
  /// Google consent flow. Macro keeps the Google refresh grant server-side.
  Future<bool> initiateGoogleOAuth({bool includeCalendar = true}) async {
    final token = _tokenProvider();
    if (token == null || token.isEmpty) {
      _setState(
        GoogleConnectionState.error,
        'Sign in to the workspace before connecting Gmail and Calendar.',
      );
      return false;
    }

    _setState(GoogleConnectionState.linking, null);

    try {
      final base = Uri.parse('${_config.authHost}/link/gmail');
      final uri = base.replace(
        queryParameters: {
          'original_url': _googleLinkCallback,
          'scopes': includeCalendar ? 'gmail_and_calendar' : 'gmail',
        },
      );
      final response = await http
          .post(uri, headers: _authHeaders(token))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        _setState(
          GoogleConnectionState.error,
          'Google authorization could not start (HTTP ${response.statusCode}).',
        );
        return false;
      }

      final data = _decodeMap(response.body);
      final authUrl = data['authorization_url']?.toString();
      if (authUrl == null || authUrl.isEmpty) {
        _setState(
          GoogleConnectionState.error,
          'The auth service returned no Google authorization URL.',
        );
        return false;
      }

      final launched = await launchUrl(
        Uri.parse(authUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        _setState(
          GoogleConnectionState.error,
          'Could not open Google authorization.',
        );
      }
      return launched;
    } catch (e) {
      _setState(
        GoogleConnectionState.error,
        'Network error initiating Google authorization: $e',
      );
      return false;
    }
  }

  Future<void> handleOAuthCallback(Uri callbackUri) async {
    final expected =
        callbackUri.scheme == 'macro' &&
        (callbackUri.host == 'google-link-callback' ||
            callbackUri.path == '/google-link-callback');
    if (!expected) return;

    await checkConnectionStatus();
  }

  Future<List<MacroCalendarSource>> fetchCalendars() async {
    final token = _tokenProvider();
    if (token == null || token.isEmpty || _accounts.isEmpty) return const [];

    try {
      final response = await http
          .get(
            Uri.parse('${_config.emailHost}/calendar/calendars'),
            headers: _authHeaders(token),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final payload = _decodeMap(response.body);
        final raw = payload['calendars'];
        _calendars = raw is List
            ? raw
                  .whereType<Map>()
                  .map((item) => MacroCalendarSource.fromJson(
                        Map<String, dynamic>.from(item),
                      ))
                  .where((calendar) => calendar.id.isNotEmpty)
                  .toList()
            : [];
        notifyListeners();
        return List.unmodifiable(_calendars);
      }

      // Calendar is an incremental permission. A Gmail account can remain
      // correctly connected even when Calendar has not yet been granted.
      _calendars = [];
      notifyListeners();
    } catch (_) {
      _calendars = [];
      notifyListeners();
    }
    return const [];
  }

  Future<List<MacroCalendarEvent>> fetchCalendarEvents({
    DateTime? start,
    DateTime? end,
  }) async {
    final token = _tokenProvider();
    if (token == null || token.isEmpty || _calendars.isEmpty) return const [];

    final rangeStart = start ?? DateTime.now().subtract(const Duration(days: 30));
    final rangeEnd = end ?? DateTime.now().add(const Duration(days: 90));
    final localStart = _formatLocalDate(rangeStart);
    final localEnd = _formatLocalDate(rangeEnd);

    final itemsByIdentity = <String, MacroCalendarEvent>{};
    final seenCursors = <String>{};
    String? cursor;
    var syncing = false;

    try {
      do {
        final uri = Uri.parse('${_config.storageHost}/calendar-events').replace(
          queryParameters: {
            'start': rangeStart.toUtc().toIso8601String(),
            'end': rangeEnd.toUtc().toIso8601String(),
            'startDate': localStart,
            'endDate': localEnd,
            'limit': '2000',
            if (cursor != null) 'cursor': cursor,
          },
        );
        final response = await http
            .get(uri, headers: _authHeaders(token))
            .timeout(const Duration(seconds: 15));

        if (response.statusCode != 200) break;

        final payload = _decodeMap(response.body);
        if (payload['syncStatus']?.toString().toLowerCase() == 'syncing') {
          syncing = true;
        }

        final rawItems = payload['items'];
        if (rawItems is List) {
          for (final raw in rawItems.whereType<Map>()) {
            final map = Map<String, dynamic>.from(raw);
            final event = MacroCalendarEvent.fromOccurrenceJson(map);
            if (event.id.isEmpty) continue;
            itemsByIdentity['${event.id}:${event.occurrenceKey}'] = event;
          }
        }

        if (payload['hasMore'] != true) break;
        final next = payload['nextCursor']?.toString();
        if (next == null || next.isEmpty || seenCursors.contains(next)) break;
        seenCursors.add(next);
        cursor = next;
      } while (cursor != null);

      _calendarSyncing = syncing;
      _calendarEvents = itemsByIdentity.values.toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
      notifyListeners();
      return List.unmodifiable(_calendarEvents);
    } catch (e) {
      if (kDebugMode) debugPrint('Calendar occurrence fetch failed: $e');
      return const [];
    }
  }

  /// Sends a verified Macro calendar create request body to email-service.
  Future<bool> createCalendarEvent(Map<String, dynamic> request) async {
    return _mutateCalendar(
      method: 'POST',
      path: '/calendar/events',
      body: request,
    );
  }

  Future<bool> updateCalendarEvent(
    String eventId,
    Map<String, dynamic> request,
  ) async {
    return _mutateCalendar(
      method: 'PATCH',
      path: '/calendar/events/${Uri.encodeComponent(eventId)}',
      body: request,
    );
  }

  Future<bool> deleteCalendarEvent(String eventId) async {
    return _mutateCalendar(
      method: 'DELETE',
      path: '/calendar/events/${Uri.encodeComponent(eventId)}',
    );
  }

  Future<bool> rsvpCalendarEvent(
    String eventId, {
    required String response,
    String? recurrenceId,
    String? scope,
  }) async {
    return _mutateCalendar(
      method: 'PUT',
      path: '/calendar/events/${Uri.encodeComponent(eventId)}/rsvp',
      body: {
        'response': response,
        if (recurrenceId != null) 'recurrenceId': recurrenceId,
        if (scope != null) 'scope': scope,
      },
    );
  }

  Future<void> disableCalendar(String linkId) async {
    final token = _tokenProvider();
    if (token == null || token.isEmpty || linkId.isEmpty) return;
    try {
      final response = await http
          .delete(
            Uri.parse(
              '${_config.emailHost}/email/links/${Uri.encodeComponent(linkId)}/calendar',
            ),
            headers: _authHeaders(token),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        await fetchCalendars();
        _calendarEvents = [];
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> disconnectGoogle([String? linkId]) async {
    final token = _tokenProvider();
    if (token == null || token.isEmpty || _accounts.isEmpty) return;

    final target = linkId == null
        ? _accounts.firstWhere(
            (account) => account.isPrimary,
            orElse: () => _accounts.first,
          )
        : _accounts.firstWhere(
            (account) => account.id == linkId,
            orElse: () => _accounts.first,
          );

    try {
      final response = await http
          .delete(
            Uri.parse(
              '${_config.emailHost}/email/links/${Uri.encodeComponent(target.id)}',
            ),
            headers: _authHeaders(token),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        await checkConnectionStatus();
      } else {
        _setState(
          GoogleConnectionState.error,
          'Could not disconnect Gmail (HTTP ${response.statusCode}).',
        );
      }
    } catch (e) {
      _setState(
        GoogleConnectionState.error,
        'Could not disconnect Gmail: $e',
      );
    }
  }

  Future<bool> _mutateCalendar({
    required String method,
    required String path,
    Map<String, dynamic>? body,
  }) async {
    final token = _tokenProvider();
    if (token == null || token.isEmpty) return false;

    try {
      final uri = Uri.parse('${_config.emailHost}$path');
      final headers = _authHeaders(token);
      final encodedBody = body == null ? null : jsonEncode(body);
      late http.Response response;
      switch (method) {
        case 'POST':
          response = await http.post(uri, headers: headers, body: encodedBody);
          break;
        case 'PATCH':
          response = await http.patch(uri, headers: headers, body: encodedBody);
          break;
        case 'PUT':
          response = await http.put(uri, headers: headers, body: encodedBody);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw ArgumentError.value(method, 'method');
      }

      final ok = response.statusCode >= 200 && response.statusCode < 300;
      if (ok) await fetchCalendarEvents();
      return ok;
    } catch (_) {
      return false;
    }
  }

  Map<String, String> _authHeaders(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  Map<String, dynamic> _decodeMap(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected a JSON object response.');
    }
    return decoded;
  }

  String _formatLocalDate(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';

  void _setState(GoogleConnectionState newState, String? error) {
    _state = newState;
    _errorMessage = error;
    notifyListeners();
  }
}
