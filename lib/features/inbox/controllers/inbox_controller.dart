import 'package:flutter/foundation.dart';
import '../../../core/persistence/local_cache.dart';
import '../../../models/models.dart';
import '../inbox_repository.dart';

class InboxController extends ChangeNotifier {
  final InboxRepository repository;
  final LocalCacheStore cacheStore;

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

  InboxController({required this.repository, required this.cacheStore});

  Future<void> loadEmails() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _emails = await repository.fetchEmails();
      if (_emails.isNotEmpty && _selectedEmail == null) {
        _selectedEmail = _emails.first;
      }
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
    repository.markAsRead(emailId);
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
