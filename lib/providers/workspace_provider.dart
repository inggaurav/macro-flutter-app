import 'package:flutter/material.dart';
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
}

class WorkspaceProvider extends ChangeNotifier {
  WorkspaceTab _activeTab = WorkspaceTab.dashboard;
  WorkspaceTab get activeTab => _activeTab;

  String _activeAiModel = 'GPT-4o (OpenAI)';
  String get activeAiModel => _activeAiModel;

  final List<String> availableAiModels = [
    'GPT-4o (OpenAI)',
    'Claude 3.5 Sonnet (Anthropic)',
    'Gemini 1.5 Pro (Google)',
    'DeepSeek V3 (Local MCP)',
  ];

  // Active Selections
  String? _selectedChannelId = 'c1';
  String? get selectedChannelId => _selectedChannelId;

  String? _selectedEmailId = 'e1';
  String? get selectedEmailId => _selectedEmailId;

  String? _selectedDocId = 'd1';
  String? get selectedDocId => _selectedDocId;

  String? _selectedDealId = 'deal1';
  String? get selectedDealId => _selectedDealId;

  bool _isCopilotDrawerOpen = false;
  bool get isCopilotDrawerOpen => _isCopilotDrawerOpen;

  // Mock Workspace Data
  List<EmailThread> emails = [
    EmailThread(
      id: 'e1',
      subject: 'Acme Corp - Q4 Renewal & Enterprise Expansion Terms',
      senderName: 'Sarah Jenkins',
      senderEmail: 'sarah.j@acmecorp.com',
      preview:
          'Hi Macro team, we reviewed the updated proposal and would like to proceed with the 50-seat add-on...',
      body:
          'Hi Macro Team,\n\nWe reviewed the updated proposal for Q4. Overall, the team is thrilled with the unified Inbox & CRM experience. We would like to add 50 more seats for our SDR team.\n\nCould you send over the updated order form by end of day?\n\nBest,\nSarah Jenkins\nVP of Ops, Acme Corp',
      timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
      isUnread: true,
      isStarred: true,
      tags: ['Sales', 'Enterprise', 'High Value'],
      linkedCompanyName: 'Acme Corp',
    ),
    EmailThread(
      id: 'e2',
      subject: 'Feedback on CRDT Real-time Document Sync Performance',
      senderName: 'David Chen',
      senderEmail: 'david.chen@linear.app',
      preview:
          'The sub-millisecond CRDT editor sync is performing incredibly well under heavy concurrency testing...',
      body:
          'Hey Team,\n\nOur team ran load tests on the document collaboration module. Even with 45 concurrent editor connections, operations reconciled cleanly without cursor drift.\n\nGreat work!',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isUnread: false,
      isStarred: false,
      tags: ['Engineering', 'Feedback'],
    ),
    EmailThread(
      id: 'e3',
      subject: 'Security Audit & SOC2 Type II Certification Progress',
      senderName: 'Elena Rostova',
      senderEmail: 'elena@cybersec.io',
      preview:
          'Final audit report is ready. All automated agent sandboxes passed penetration testing...',
      body:
          'Hi Team,\n\nThe SOC2 Type II audit report has been finalized. All agent execution isolation and encryption protocols have passed with zero findings.\n\nRegards,\nElena',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isUnread: true,
      isStarred: true,
      tags: ['Compliance', 'Security'],
    ),
  ];

  List<ChatChannel> channels = [
    ChatChannel(
      id: 'c1',
      name: 'general',
      description: 'Company-wide updates & announcements',
      unreadCount: 2,
      lastActivity: DateTime.now(),
    ),
    ChatChannel(
      id: 'c2',
      name: 'engineering',
      description: 'Core CRDT, AI agents & Flutter platform',
      unreadCount: 0,
      lastActivity: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    ChatChannel(
      id: 'c3',
      name: 'sales-deals',
      description: '@-linked CRM deals & ARR pipeline',
      unreadCount: 5,
      lastActivity: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    ChatChannel(
      id: 'c4',
      name: 'ai-agents-memory',
      description: 'Agent swarm logs & MCP memory updates',
      unreadCount: 1,
      lastActivity: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  List<ChatMessage> chatMessages = [
    ChatMessage(
      id: 'm1',
      channelId: 'c1',
      senderName: 'Alex Rivera',
      senderAvatar:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
      text:
          'Just deployed the updated CRDT collaborative document engine to production! @Task-102 is now complete. 🚀',
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      mentions: ['@Task-102', '@Docs/CRDT-Spec'],
    ),
    ChatMessage(
      id: 'm2',
      channelId: 'c1',
      senderName: 'Macro AI Agent',
      senderAvatar:
          'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&q=80&w=200',
      text:
          '🤖 Automated Memory Synthesis: Linked @Task-102 to @Acme Corp ARR deal (\$120k). Updated workspace memory context.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 44)),
      isAgent: true,
      mentions: ['@Acme Corp'],
    ),
    ChatMessage(
      id: 'm3',
      channelId: 'c1',
      senderName: 'Jordan Vance',
      senderAvatar:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=200',
      text:
          'Amazing! Sarah from @Acme Corp just confirmed they are ready to sign the 50-seat expansion proposal.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      mentions: ['@Acme Corp'],
    ),
    ChatMessage(
      id: 'm4',
      channelId: 'c2',
      senderName: 'David Chen',
      senderAvatar:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=200',
      text:
          'PR #402 for Flutter CRDT state synchronization is ready for review.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      mentions: ['@PR-402'],
    ),
    ChatMessage(
      id: 'm5',
      channelId: 'c3',
      senderName: 'Elena Rostova',
      senderAvatar:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=200',
      text: 'Acme Corp contract updated: \$120,000 ARR with 3-year term.',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      mentions: ['@Acme Corp'],
    ),
    ChatMessage(
      id: 'm6',
      channelId: 'c4',
      senderName: 'Swarm Memory Bot',
      senderAvatar:
          'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&q=80&w=200',
      text:
          '🤖 Agent Swarm: Embedded 4 new vector fragments into workspace memory.',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      isAgent: true,
      mentions: [],
    ),
  ];

  List<DocumentItem> documents = [
    DocumentItem(
      id: 'd1',
      title: 'Macro Product Architecture & Unified Memory Model',
      content: '''# Macro Unified Workspace PRD

Macro combines Email, Team Chat, Collaborative Docs, Task Management, CRM, and AI Memory into a single multi-modal platform.

## Key Principles
1. **@-linking Everything**: Every doc, email, deal, task, and contact is bidirectionally linked.
2. **Shared Team Memory**: Daily agentic synthesis creates persistent memory across OpenAI, Anthropic & Google models.
3. **CRDT Collaboration**: Sub-millisecond real-time document editing without server locks.

## Core Services
- **Inbox & Mailer**: Fast unified thread inbox
- **Realtime Chat**: Slack-style channels with AI co-pilots
- **Kanban CRM**: Self-updating pipeline tied to company conversations
''',
      authorName: 'Alex Rivera',
      lastModified: DateTime.now().subtract(const Duration(hours: 1)),
      tags: ['PRD', 'Architecture', 'AI'],
      versionCount: 14,
      isPinned: true,
    ),
    DocumentItem(
      id: 'd2',
      title: 'Q4 Sales Playbook & Enterprise Pipeline',
      content: '''# Q4 Enterprise Sales Playbook

### Active Target Accounts
- **Acme Corp**: \$120,000 ARR (Stage: Negotiation)
- **Stripe Integration Partner**: \$85,000 ARR (Stage: Proposal)
- **Vercel Ecosystem**: \$150,000 ARR (Stage: Lead)
''',
      authorName: 'Jordan Vance',
      lastModified: DateTime.now().subtract(const Duration(hours: 4)),
      tags: ['Sales', 'CRM', 'Q4'],
      versionCount: 6,
      isPinned: false,
    ),
  ];

  List<TaskItem> tasks = [
    TaskItem(
      id: 't1',
      title: 'Implement Multi-Model AI Agent Selector',
      description:
          'Allow users to switch between GPT-4o, Claude 3.5 Sonnet, and Gemini 1.5 Pro dynamically in chat & docs.',
      status: TaskStatus.inProgress,
      priority: TaskPriority.urgent,
      assigneeName: 'Alex Rivera',
      assigneeAvatar:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
      dueDate: DateTime.now().add(const Duration(days: 1)),
      tags: ['AI', 'Feature'],
    ),
    TaskItem(
      id: 't2',
      title: 'Sync CRM Pipeline Deals with Email @mentions',
      description:
          'Automatically link incoming email threads to matching CRM company records.',
      status: TaskStatus.todo,
      priority: TaskPriority.high,
      assigneeName: 'Jordan Vance',
      assigneeAvatar:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=200',
      dueDate: DateTime.now().add(const Duration(days: 3)),
      tags: ['CRM', 'Backend'],
    ),
    TaskItem(
      id: 't3',
      title: 'CRDT Conflict Resolution Benchmarks',
      description:
          'Validate 50+ concurrent websocket sessions in Flutter document editor.',
      status: TaskStatus.done,
      priority: TaskPriority.medium,
      assigneeName: 'David Chen',
      assigneeAvatar:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=200',
      dueDate: DateTime.now().subtract(const Duration(days: 1)),
      tags: ['Benchmark', 'Docs'],
    ),
  ];

  List<CrmDeal> deals = [
    CrmDeal(
      id: 'deal1',
      title: 'Acme Corp - 50 Seat Add-on',
      companyName: 'Acme Corp',
      value: 120000.0,
      stage: DealStage.negotiation,
      contactName: 'Sarah Jenkins',
      contactEmail: 'sarah.j@acmecorp.com',
      lastInteraction: 'Email received 18m ago',
      tags: ['Enterprise', 'High Priority'],
    ),
    CrmDeal(
      id: 'deal2',
      title: 'FinTech Global Workspace Rollout',
      companyName: 'FinTech Systems',
      value: 85000.0,
      stage: DealStage.proposal,
      contactName: 'Michael Chang',
      contactEmail: 'm.chang@fintech.io',
      lastInteraction: 'Call completed yesterday',
      tags: ['Fintech', 'Mid-Market'],
    ),
    CrmDeal(
      id: 'deal3',
      title: 'HyperScale Cloud Migration Contract',
      companyName: 'CloudPulse',
      value: 195000.0,
      stage: DealStage.closedWon,
      contactName: 'Elena Rostova',
      contactEmail: 'elena@cloudpulse.tech',
      lastInteraction: 'Contract signed',
      tags: ['Cloud', 'Closed'],
    ),
  ];

  List<AiMemoryItem> memories = [
    AiMemoryItem(
      id: 'm1',
      category: 'sales_insight',
      title: 'Acme Corp Buying Criteria',
      summary:
          'Acme Corp requires SOC2 Type II compliance and offline CRDT sync for their mobile SDR team.',
      source: 'Email #e1 & Chat #c3',
      confidence: 0.98,
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    AiMemoryItem(
      id: 'm2',
      category: 'tech_stack',
      title: 'CRDT Document Synchronization Protocol',
      summary:
          'Flutter mobile client reconciles delta vectors using Yjs/Automerge binary payloads over WebSocket.',
      source: 'Doc #d1 Architecture',
      confidence: 0.95,
      updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    AiMemoryItem(
      id: 'm3',
      category: 'team_context',
      title: 'Q4 Target ARR Goal',
      summary:
          'Team target is \$400k ARR expansion across 3 main enterprise accounts before end of Q4.',
      source: 'Daily Agent Memory Synthesis',
      confidence: 0.99,
      updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
  ];

  List<CallSession> callSessions = [
    CallSession(
      id: 'call1',
      title: 'Weekly Workspace Engineering & AI Alignment',
      isLive: true,
      durationMinutes: 24,
      participantAvatars: [
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=200',
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=200',
      ],
      liveTranscript:
          '[00:22:15] Alex: The Flutter state model reconciles tasks and CRM deals in real-time.\n[00:23:02] Jordan: Sarah confirmed the \$120k contract terms.',
      aiSummary:
          'Engineering team reviewed CRDT performance. Sales team confirmed Acme Corp \$120k contract progress.',
    ),
  ];

  // Actions
  void setTab(WorkspaceTab tab) {
    _activeTab = tab;
    notifyListeners();
  }

  void setAiModel(String model) {
    _activeAiModel = model;
    notifyListeners();
  }

  void selectChannel(String id) {
    _selectedChannelId = id;
    notifyListeners();
  }

  void selectEmail(String id) {
    _selectedEmailId = id;
    // Mark email as read
    final idx = emails.indexWhere((e) => e.id == id);
    if (idx != -1) {
      emails[idx] = EmailThread(
        id: emails[idx].id,
        subject: emails[idx].subject,
        senderName: emails[idx].senderName,
        senderEmail: emails[idx].senderEmail,
        preview: emails[idx].preview,
        body: emails[idx].body,
        timestamp: emails[idx].timestamp,
        isUnread: false,
        isStarred: emails[idx].isStarred,
        tags: emails[idx].tags,
        linkedCompanyName: emails[idx].linkedCompanyName,
      );
    }
    notifyListeners();
  }

  void selectDoc(String id) {
    _selectedDocId = id;
    notifyListeners();
  }

  void selectDeal(String id) {
    _selectedDealId = id;
    notifyListeners();
  }

  void toggleCopilotDrawer() {
    _isCopilotDrawerOpen = !_isCopilotDrawerOpen;
    notifyListeners();
  }

  void addChatMessage(String text, {String? targetChannelId}) {
    if (text.trim().isEmpty) return;

    final String cId = targetChannelId ?? selectedChannelId ?? 'c1';
    final newMsg = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      channelId: cId,
      senderName: 'You (Alex)',
      senderAvatar:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
      text: text,
      timestamp: DateTime.now(),
      mentions: text.contains('@') ? ['@Mentioned'] : [],
    );

    chatMessages.add(newMsg);

    // Simulate AI Agent Auto-response if message asks AI
    if (text.toLowerCase().contains('ai') ||
        text.toLowerCase().contains('macro') ||
        text.contains('@ai')) {
      Future.delayed(const Duration(seconds: 1), () {
        chatMessages.add(
          ChatMessage(
            id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
            channelId: cId,
            senderName: 'Macro AI Agent ($_activeAiModel)',
            senderAvatar:
                'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&q=80&w=200',
            text:
                '🤖 I synthesized team context from @Acme Corp and @Docs/PRD. Here is the response for "$text". All linked objects are synced.',
            timestamp: DateTime.now(),
            isAgent: true,
            mentions: ['@Acme Corp'],
          ),
        );
        notifyListeners();
      });
    }

    notifyListeners();
  }

  void updateTaskStatus(String taskId, TaskStatus newStatus) {
    final idx = tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      tasks[idx].status = newStatus;
      notifyListeners();
    }
  }

  void updateDealStage(String dealId, DealStage newStage) {
    final idx = deals.indexWhere((d) => d.id == dealId);
    if (idx != -1) {
      deals[idx].stage = newStage;
      notifyListeners();
    }
  }
}
