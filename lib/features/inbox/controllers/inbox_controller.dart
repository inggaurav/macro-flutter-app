import 'package:flutter/foundation.dart';
import '../../../core/persistence/local_cache.dart';
import '../domain/email_thread.dart';
import '../inbox_repository.dart';

class InboxController extends ChangeNotifier {
  final InboxRepository repository;
  final LocalCacheStore cacheStore;
  final String workspaceId;

  List<EmailThread> _emails = [];
  EmailThread? _selectedEmail;
  bool _isLoading = false;
  bool _isGeneratingAiReply = false;
  String? _generatedReplyDraft;
  String? _errorMessage;

  List<EmailThread> get emails => List.unmodifiable(_emails);
  EmailThread? get selectedEmail => _selectedEmail;
  bool get isLoading => _isLoading;
  bool get isGeneratingAiReply => _isGeneratingAiReply;
  String? get generatedReplyDraft => _generatedReplyDraft;
  String? get errorMessage => _errorMessage;

  String get _inboxCacheKey => 'workspace:$workspaceId:inbox:threads';

  InboxController({
    required this.repository,
    required this.cacheStore,
    this.workspaceId = 'default',
  });

  Future<void> loadEmails() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // 1. Read cached email threads first
    final cachedJson = await cacheStore.get(_inboxCacheKey);
    if (cachedJson is List) {
      try {
        _emails = cachedJson
            .map((e) => EmailThread.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        if (_emails.isNotEmpty && _selectedEmail == null) {
          _selectedEmail = _emails.first;
        }
        notifyListeners();
      } catch (_) {}
    }

    // 2. Fetch repository emails (stale-while-revalidate)
    try {
      final remoteEmails = await repository.fetchEmails();
      _emails = remoteEmails;
      if (_emails.isNotEmpty && _selectedEmail == null) {
        _selectedEmail = _emails.first;
      }

      // 3. Persist to cache
      final jsonList = _emails.map((e) => e.toJson()).toList();
      await cacheStore.put(_inboxCacheKey, jsonList);
    } catch (e) {
      _errorMessage = 'Failed to load email threads: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectEmail(String emailId) {
    final email = _emails.firstWhere(
      (e) => e.id == emailId,
      orElse: () => _emails.first,
    );
    _selectedEmail = email;
    _generatedReplyDraft = null;
    notifyListeners();
    markAsRead(emailId);
  }

  Future<void> markAsRead(String emailId) async {
    final idx = _emails.indexWhere((e) => e.id == emailId);
    if (idx != -1) {
      final old = _emails[idx];
      _emails[idx] = EmailThread(
        id: old.id,
        subject: old.subject,
        senderName: old.senderName,
        senderEmail: old.senderEmail,
        preview: old.preview,
        body: old.body,
        timestamp: old.timestamp,
        isUnread: false,
        isStarred: old.isStarred,
        tags: old.tags,
        linkedCompanyName: old.linkedCompanyName,
      );
      notifyListeners();
      await repository.markAsRead(emailId);

      // Update cache
      final jsonList = _emails.map((e) => e.toJson()).toList();
      await cacheStore.put(_inboxCacheKey, jsonList);
    }
  }

  Future<void> generateAiReply(String emailId) async {
    _isGeneratingAiReply = true;
    notifyListeners();

    try {
      _generatedReplyDraft = await repository.generateAiReply(emailId);
    } catch (e) {
      _errorMessage = 'Failed to generate AI reply draft: $e';
    } finally {
      _isGeneratingAiReply = false;
      notifyListeners();
    }
  }
}
