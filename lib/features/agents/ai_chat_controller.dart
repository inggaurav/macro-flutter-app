import 'package:flutter/foundation.dart';
import 'agent_repository.dart';

class AiChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  AiChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class AiChatController extends ChangeNotifier {
  final AgentRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  final List<AiChatMessage> _messages = [];

  AiChatController({required AgentRepository repository})
    : _repository = repository;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<AiChatMessage> get messages => List.unmodifiable(_messages);

  Future<void> sendPrompt(String prompt) async {
    if (prompt.trim().isEmpty) return;

    final userMsg = AiChatMessage(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      text: prompt.trim(),
      isUser: true,
    );
    _messages.add(userMsg);
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final responseText = await _repository.queryCopilot(prompt.trim());
      final aiMsg = AiChatMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        text: responseText,
        isUser: false,
      );
      _messages.add(aiMsg);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
