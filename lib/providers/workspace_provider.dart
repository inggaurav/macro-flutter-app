import 'package:flutter/foundation.dart';
import '../models/models.dart';

enum WorkspaceTab {
  dashboard,
  inbox,
  chat,
  docs,
  tasks,
  crm,
  aiMemory,
  calls,
  settings,
  profile,
}

class WorkspaceProvider extends ChangeNotifier {
  WorkspaceTab _activeTab = WorkspaceTab.dashboard;
  String _activeAiModel = 'Gemini 1.5 Pro';
  bool _isCopilotDrawerOpen = false;
  String? _selectedDocId;

  final List<String> _availableAiModels = [
    'Gemini 1.5 Pro',
    'Claude 3.5 Sonnet',
    'GPT-4o',
    'DeepSeek R1',
  ];

  final List<DocumentItem> _documents = [
    DocumentItem(
      id: 'd1',
      title: 'Macro Architecture & CRDT Engine Protocol',
      content: '''# Macro Architecture & CRDT Engine Protocol

## Multi-Region State Replication
This document specifies the real-time conflict-free replicated data type (CRDT) engine protocol used across Macro workspace clients.
''',
      authorName: 'Alex Rivera',
      lastModified: DateTime.now().subtract(const Duration(hours: 4)),
      tags: ['Architecture', 'Engineering'],
      isPinned: true,
    ),
  ];

  final List<TaskItem> _tasks = [
    TaskItem(
      id: 't1',
      title: 'Harden SecureStorageService with Android Keystore fail-closed semantics',
      description: 'Ensure platform storage throws explicit exception rather than fallback silently to memory map.',
      status: TaskStatus.inProgress,
      priority: TaskPriority.urgent,
      assigneeName: 'Alex Rivera',
      assigneeAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
      dueDate: DateTime.now().add(const Duration(days: 1)),
      tags: ['Security', 'Storage'],
    ),
  ];

  final List<CrmDeal> _crmDeals = [
    CrmDeal(
      id: 'cd1',
      title: 'Vortex.io Enterprise License & MCP Swarm',
      companyName: 'Vortex Systems',
      value: 120000.0,
      stage: DealStage.proposal,
      contactName: 'Sarah Jenkins',
      contactEmail: 'sarah@vortex.io',
      lastInteraction: '2 hours ago',
      tags: ['Enterprise', 'Q3 Pipeline'],
    ),
  ];

  final List<AiMemoryItem> _aiMemories = [
    AiMemoryItem(
      id: 'm1',
      category: 'team_context',
      title: 'WebSocket Latency SLA',
      summary: 'Multi-region real-time sync target is established at <45ms across edge nodes.',
      source: 'Slack #engineering',
      confidence: 0.98,
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  final List<CallSession> _callSessions = [
    CallSession(
      id: 'cs1',
      title: 'Weekly Engineering Sync & App Factory Architecture',
      isLive: false,
      durationMinutes: 45,
      participantAvatars: [
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=200',
      ],
      liveTranscript: '[00:12] Alex: Flutter secure storage fail-closed implementation complete.',
      aiSummary: 'Decided to fail closed on platform secure storage errors. Decomposed WorkspaceProvider into modular controllers.',
    ),
  ];

  // Getters
  WorkspaceTab get activeTab => _activeTab;
  String get activeAiModel => _activeAiModel;
  List<String> get availableAiModels => List.unmodifiable(_availableAiModels);
  bool get isCopilotDrawerOpen => _isCopilotDrawerOpen;
  bool get isCopilotOpen => _isCopilotDrawerOpen;
  String? get selectedDocId => _selectedDocId ?? (_documents.isNotEmpty ? _documents.first.id : null);

  List<DocumentItem> get documents => List.unmodifiable(_documents);
  List<TaskItem> get tasks => List.unmodifiable(_tasks);
  List<CrmDeal> get crmDeals => List.unmodifiable(_crmDeals);
  List<CrmDeal> get deals => List.unmodifiable(_crmDeals);
  List<AiMemoryItem> get aiMemories => List.unmodifiable(_aiMemories);
  List<AiMemoryItem> get memories => List.unmodifiable(_aiMemories);
  List<CallSession> get callSessions => List.unmodifiable(_callSessions);

  void setTab(WorkspaceTab tab) {
    _activeTab = tab;
    notifyListeners();
  }

  void setActiveTab(String tabName) {
    final tab = WorkspaceTab.values.firstWhere(
      (t) => t.name == tabName,
      orElse: () => WorkspaceTab.dashboard,
    );
    setTab(tab);
  }

  void setAiModel(String model) {
    _activeAiModel = model;
    notifyListeners();
  }

  void toggleCopilotDrawer() {
    _isCopilotDrawerOpen = !_isCopilotDrawerOpen;
    notifyListeners();
  }

  void selectDoc(String docId) {
    _selectedDocId = docId;
    notifyListeners();
  }

  void updateTaskStatus(String taskId, TaskStatus status) {
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      _tasks[taskIndex].status = status;
      notifyListeners();
    }
  }

  void updateDealStage(String dealId, DealStage stage) {
    final dealIndex = _crmDeals.indexWhere((d) => d.id == dealId);
    if (dealIndex != -1) {
      _crmDeals[dealIndex].stage = stage;
      notifyListeners();
    }
  }
}
